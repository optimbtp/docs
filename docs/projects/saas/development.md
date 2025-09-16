# SAAS Platform Development Guide

This guide provides comprehensive information for developers working on the SAAS Platform, including architecture, development practices, and deployment procedures.

## Development Environment Setup

### Prerequisites

- **Node.js** (18.0 or higher)
- **npm** or **yarn** package manager
- **PostgreSQL** (14.0 or higher)
- **Redis** (6.0 or higher)
- **Docker** and **Docker Compose**
- **Git** for version control

### Local Development Setup

1. **Clone Repository**

   ```bash
   git clone https://github.com/optim/saas-platform.git
   cd saas-platform
   ```

2. **Install Dependencies**

   ```bash
   # Backend dependencies
   cd backend
   npm install

   # Frontend dependencies
   cd ../frontend
   npm install

   # Return to root
   cd ..
   ```

3. **Environment Configuration**

   ```bash
   # Copy environment templates
   cp backend/.env.example backend/.env
   cp frontend/.env.example frontend/.env

   # Configure environment variables
   # Edit .env files with your local settings
   ```

4. **Database Setup**

   ```bash
   # Start PostgreSQL and Redis with Docker
   docker-compose up -d postgres redis

   # Run database migrations
   cd backend
   npm run migrate

   # Seed with development data
   npm run seed
   ```

5. **Start Development Servers**

   ```bash
   # Terminal 1: Backend API
   cd backend
   npm run dev

   # Terminal 2: Frontend
   cd frontend
   npm run dev

   # Terminal 3: Background jobs (optional)
   cd backend
   npm run worker
   ```

## Project Structure

```
saas-platform/
├── backend/                    # Node.js API server
│   ├── src/
│   │   ├── controllers/        # Request handlers
│   │   ├── services/          # Business logic
│   │   ├── models/            # Database models
│   │   ├── middleware/        # Express middleware
│   │   ├── routes/            # API routes
│   │   ├── utils/             # Utility functions
│   │   └── types/             # TypeScript types
│   ├── migrations/            # Database migrations
│   ├── seeds/                 # Development data
│   └── tests/                 # Backend tests
├── frontend/                  # React application
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── pages/            # Page components
│   │   ├── hooks/            # Custom hooks
│   │   ├── services/         # API client
│   │   ├── store/            # Redux store
│   │   ├── utils/            # Frontend utilities
│   │   └── types/            # TypeScript types
│   ├── public/               # Static assets
│   └── tests/                # Frontend tests
├── shared/                   # Shared code and types
├── infrastructure/           # Infrastructure as code
├── docs/                    # Technical documentation
└── scripts/                 # Build and deployment scripts
```

## Architecture Overview

### Multi-Tenant Architecture

```typescript
// Tenant isolation strategy
interface TenantContext {
  tenantId: string;
  schema: string;
  features: Feature[];
  limits: ResourceLimits;
}

// Middleware for tenant resolution
export const resolveTenant = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const tenantId = extractTenantId(req);
  const tenant = await getTenantById(tenantId);

  if (!tenant) {
    return res.status(404).json({ error: "Tenant not found" });
  }

  req.tenant = tenant;
  next();
};
```

### Database Schema Design

```sql
-- Multi-tenant schema design
CREATE SCHEMA tenant_core;
CREATE SCHEMA tenant_data;

-- Core tables (shared across tenants)
CREATE TABLE tenant_core.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  domain VARCHAR(255) UNIQUE,
  schema_name VARCHAR(63) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  settings JSONB DEFAULT '{}'
);

-- Tenant-specific tables (per tenant schema)
CREATE TABLE tenant_data.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenant_core.tenants(id),
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user',
  created_at TIMESTAMP DEFAULT NOW()
);
```

### API Design Patterns

#### RESTful API Structure

```typescript
// User controller example
export class UserController {
  async getUsers(req: AuthenticatedRequest, res: Response) {
    try {
      const { tenant } = req;
      const { page = 1, limit = 20, search } = req.query;

      const users = await this.userService.getUsers(tenant.id, {
        page: Number(page),
        limit: Number(limit),
        search: search as string,
      });

      res.json({
        data: users.data,
        pagination: users.pagination,
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async createUser(req: AuthenticatedRequest, res: Response) {
    try {
      const { tenant } = req;
      const userData = this.validateUserData(req.body);

      const user = await this.userService.createUser(tenant.id, userData);

      res.status(201).json({ data: user });
    } catch (error) {
      this.handleError(error, res);
    }
  }
}
```

#### GraphQL Implementation

```typescript
// GraphQL resolver example
export const userResolvers = {
  Query: {
    users: async (
      _: any,
      args: { filter?: UserFilter; pagination?: Pagination },
      context: AuthContext
    ) => {
      await requirePermission(context, "read:users");

      return userService.getUsers(context.tenant.id, args);
    },
  },

  Mutation: {
    createUser: async (
      _: any,
      args: { input: CreateUserInput },
      context: AuthContext
    ) => {
      await requirePermission(context, "create:users");

      return userService.createUser(context.tenant.id, args.input);
    },
  },
};
```

## Frontend Development

### Component Architecture

```typescript
// Feature-based component structure
interface UserListProps {
  tenantId: string;
  filters?: UserFilters;
  onUserSelect?: (user: User) => void;
}

export const UserList: React.FC<UserListProps> = ({
  tenantId,
  filters,
  onUserSelect,
}) => {
  const { data: users, isLoading, error } = useUsers(tenantId, filters);
  const { mutate: deleteUser } = useDeleteUser();

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div className="user-list">
      {users?.map((user) => (
        <UserCard
          key={user.id}
          user={user}
          onSelect={onUserSelect}
          onDelete={() => deleteUser(user.id)}
        />
      ))}
    </div>
  );
};
```

### State Management

```typescript
// Redux store configuration
export interface AppState {
  auth: AuthState;
  tenant: TenantState;
  users: UsersState;
  ui: UIState;
}

// Tenant slice
export const tenantSlice = createSlice({
  name: "tenant",
  initialState: {
    current: null as Tenant | null,
    settings: {},
    features: [],
    loading: false,
  },
  reducers: {
    setCurrentTenant: (state, action) => {
      state.current = action.payload;
    },
    updateTenantSettings: (state, action) => {
      if (state.current) {
        state.current.settings = {
          ...state.current.settings,
          ...action.payload,
        };
      }
    },
  },
});
```

### Custom Hooks

```typescript
// Custom hook for API data fetching
export const useUsers = (tenantId: string, filters?: UserFilters) => {
  return useQuery(
    ["users", tenantId, filters],
    () => userApi.getUsers(tenantId, filters),
    {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      refetchOnWindowFocus: false,
    }
  );
};

// Custom hook for mutations
export const useCreateUser = () => {
  const queryClient = useQueryClient();

  return useMutation((data: CreateUserData) => userApi.createUser(data), {
    onSuccess: (newUser) => {
      queryClient.invalidateQueries(["users"]);
      toast.success("User created successfully");
    },
    onError: (error) => {
      toast.error("Failed to create user");
      console.error("User creation error:", error);
    },
  });
};
```

## Authentication & Authorization

### JWT Implementation

```typescript
// JWT service
export class AuthService {
  private readonly jwtSecret = process.env.JWT_SECRET!;

  generateToken(user: User, tenant: Tenant): string {
    const payload = {
      userId: user.id,
      tenantId: tenant.id,
      email: user.email,
      role: user.role,
      permissions: this.getUserPermissions(user, tenant),
    };

    return jwt.sign(payload, this.jwtSecret, {
      expiresIn: "24h",
      issuer: "saas-platform",
      audience: tenant.domain,
    });
  }

  verifyToken(token: string): TokenPayload {
    try {
      return jwt.verify(token, this.jwtSecret) as TokenPayload;
    } catch (error) {
      throw new AuthenticationError("Invalid token");
    }
  }
}
```

### Permission System

```typescript
// Permission definitions
export enum Permission {
  READ_USERS = "read:users",
  CREATE_USERS = "create:users",
  UPDATE_USERS = "update:users",
  DELETE_USERS = "delete:users",
  MANAGE_TENANT = "manage:tenant",
  VIEW_ANALYTICS = "view:analytics",
}

// Role-based permissions
export const ROLE_PERMISSIONS: Record<string, Permission[]> = {
  admin: Object.values(Permission),
  manager: [
    Permission.READ_USERS,
    Permission.CREATE_USERS,
    Permission.UPDATE_USERS,
    Permission.VIEW_ANALYTICS,
  ],
  user: [Permission.READ_USERS],
};

// Permission middleware
export const requirePermission = (permission: Permission) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.user.permissions.includes(permission)) {
      return res.status(403).json({ error: "Insufficient permissions" });
    }
    next();
  };
};
```

## Testing Strategy

### Backend Testing

```typescript
// Unit test example
describe("UserService", () => {
  let userService: UserService;
  let mockRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepository = createMockUserRepository();
    userService = new UserService(mockRepository);
  });

  describe("createUser", () => {
    it("should create a user with valid data", async () => {
      const userData = {
        email: "test@example.com",
        name: "Test User",
        role: "user",
      };

      const expectedUser = { id: "123", ...userData };
      mockRepository.create.mockResolvedValue(expectedUser);

      const result = await userService.createUser("tenant-1", userData);

      expect(result).toEqual(expectedUser);
      expect(mockRepository.create).toHaveBeenCalledWith("tenant-1", userData);
    });
  });
});

// Integration test example
describe("User API", () => {
  let app: Application;
  let tenantId: string;
  let authToken: string;

  beforeAll(async () => {
    app = await createTestApp();
    const { tenant, token } = await setupTestTenant();
    tenantId = tenant.id;
    authToken = token;
  });

  describe("POST /api/users", () => {
    it("should create a new user", async () => {
      const userData = {
        email: "newuser@example.com",
        name: "New User",
        role: "user",
      };

      const response = await request(app)
        .post("/api/users")
        .set("Authorization", `Bearer ${authToken}`)
        .send(userData)
        .expect(201);

      expect(response.body.data).toMatchObject(userData);
    });
  });
});
```

### Frontend Testing

```typescript
// Component test example
import { render, screen, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "react-query";
import { UserList } from "../UserList";

describe("UserList", () => {
  const mockUsers = [
    { id: "1", name: "John Doe", email: "john@example.com" },
    { id: "2", name: "Jane Smith", email: "jane@example.com" },
  ];

  const renderWithProviders = (component: React.ReactElement) => {
    const queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } },
    });

    return render(
      <QueryClientProvider client={queryClient}>
        {component}
      </QueryClientProvider>
    );
  };

  it("should render user list", async () => {
    jest.spyOn(userApi, "getUsers").mockResolvedValue(mockUsers);

    renderWithProviders(<UserList tenantId="tenant-1" />);

    expect(await screen.findByText("John Doe")).toBeInTheDocument();
    expect(await screen.findByText("Jane Smith")).toBeInTheDocument();
  });
});
```

## Performance Optimization

### Database Optimization

```typescript
// Query optimization
export class UserRepository {
  async getUsersWithPagination(
    tenantId: string,
    options: PaginationOptions
  ): Promise<PaginatedResult<User>> {
    const { page, limit, search } = options;
    const offset = (page - 1) * limit;

    // Optimized query with proper indexing
    const query = this.db
      .select("*")
      .from("users")
      .where("tenant_id", tenantId)
      .andWhere((builder) => {
        if (search) {
          builder
            .where("name", "ilike", `%${search}%`)
            .orWhere("email", "ilike", `%${search}%`);
        }
      })
      .orderBy("created_at", "desc")
      .limit(limit)
      .offset(offset);

    const [users, totalCount] = await Promise.all([
      query,
      this.getUserCount(tenantId, search),
    ]);

    return {
      data: users,
      pagination: {
        page,
        limit,
        total: totalCount,
        pages: Math.ceil(totalCount / limit),
      },
    };
  }
}
```

### Caching Strategy

```typescript
// Redis caching implementation
export class CacheService {
  private redis: Redis;

  constructor() {
    this.redis = new Redis(process.env.REDIS_URL);
  }

  async get<T>(key: string): Promise<T | null> {
    const cached = await this.redis.get(key);
    return cached ? JSON.parse(cached) : null;
  }

  async set(key: string, value: any, ttl: number = 3600): Promise<void> {
    await this.redis.setex(key, ttl, JSON.stringify(value));
  }

  async invalidate(pattern: string): Promise<void> {
    const keys = await this.redis.keys(pattern);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }
}

// Cache decorator
export const cached = (ttl: number = 3600) => {
  return (
    target: any,
    propertyName: string,
    descriptor: PropertyDescriptor
  ) => {
    const method = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      const cacheKey = `${
        target.constructor.name
      }:${propertyName}:${JSON.stringify(args)}`;

      let result = await this.cacheService.get(cacheKey);
      if (!result) {
        result = await method.apply(this, args);
        await this.cacheService.set(cacheKey, result, ttl);
      }

      return result;
    };
  };
};
```

## Deployment

### Docker Configuration

```dockerfile
# Backend Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

USER nodejs

EXPOSE 3000
ENV NODE_ENV production

CMD ["npm", "start"]
```

### Kubernetes Deployment

```yaml
# Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: saas-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: saas-backend
  template:
    metadata:
      labels:
        app: saas-backend
    spec:
      containers:
        - name: backend
          image: optim/saas-backend:latest
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: url
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: redis-secret
                  key: url
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
```

## Monitoring and Observability

### Logging

Pour la journalisation et la gestion des erreurs, nous utilisons **Sentry** pour capturer et tracker les erreurs côté API (FastAPI) et frontend (React + TypeScript).

📖 **[Consultez le guide complet de journalisation et Sentry](logging.md)**

Ce guide détaillé couvre :

- Configuration FastAPI avec Sentry SDK
- Intégration React + TypeScript avec Sentry
- Upload des sourcemaps et configuration des releases
- Exemples pratiques et bonnes pratiques
- Gestion des variables d'environnement
- Checklist de déploiement

### Metrics

```typescript
// Prometheus metrics
import client from "prom-client";

export const metrics = {
  httpRequestDuration: new client.Histogram({
    name: "http_request_duration_seconds",
    help: "HTTP request duration in seconds",
    labelNames: ["method", "route", "status_code", "tenant_id"],
  }),

  activeConnections: new client.Gauge({
    name: "active_connections_total",
    help: "Total number of active connections",
  }),

  databaseConnections: new client.Gauge({
    name: "database_connections_active",
    help: "Number of active database connections",
  }),
};

// Metrics middleware
export const metricsMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const start = Date.now();

  res.on("finish", () => {
    const duration = (Date.now() - start) / 1000;

    metrics.httpRequestDuration.observe(
      {
        method: req.method,
        route: req.route?.path || req.path,
        status_code: res.statusCode.toString(),
        tenant_id: req.tenant?.id || "unknown",
      },
      duration
    );
  });

  next();
};
```

## Security Best Practices

### Input Validation

```typescript
// Request validation with Joi
import Joi from "joi";

export const userSchema = Joi.object({
  email: Joi.string().email().required(),
  name: Joi.string().min(2).max(100).required(),
  role: Joi.string().valid("admin", "manager", "user").default("user"),
  permissions: Joi.array().items(Joi.string()).optional(),
});

export const validateRequest = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error, value } = schema.validate(req.body);

    if (error) {
      return res.status(400).json({
        error: "Validation failed",
        details: error.details.map((d) => d.message),
      });
    }

    req.body = value;
    next();
  };
};
```

### Rate Limiting

```typescript
// Rate limiting implementation
import rateLimit from "express-rate-limit";
import RedisStore from "rate-limit-redis";

export const createRateLimiter = (
  windowMs: number,
  max: number,
  keyGenerator?: (req: Request) => string
) => {
  return rateLimit({
    store: new RedisStore({
      client: redis,
      prefix: "rl:",
    }),
    windowMs,
    max,
    keyGenerator: keyGenerator || ((req) => req.ip),
    message: "Too many requests from this IP, please try again later.",
    standardHeaders: true,
    legacyHeaders: false,
  });
};

// Apply different limits based on endpoint
export const apiLimiter = createRateLimiter(15 * 60 * 1000, 100); // 100 requests per 15 minutes
export const authLimiter = createRateLimiter(15 * 60 * 1000, 5); // 5 login attempts per 15 minutes
```

## Contributing Guidelines

### Code Standards

- **TypeScript**: Use strict type checking
- **ESLint**: Follow configured linting rules
- **Prettier**: Consistent code formatting
- **Tests**: Maintain >80% code coverage
- **Documentation**: Update docs for new features

### Git Workflow

```bash
# Feature development workflow
git checkout -b feature/user-management-improvements
git commit -m "feat(users): add bulk user import functionality"
git push origin feature/user-management-improvements

# Create pull request with proper template
# Wait for code review and CI checks
# Merge after approval
```

### Pull Request Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Breaking changes documented
```

---

_For development questions or support, contact the SAAS Development Team at saas-dev@optim.com_
