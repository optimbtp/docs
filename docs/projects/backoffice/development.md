# Backoffice Platform Development Guide

This guide provides comprehensive information for developers working on the Backoffice Platform, including architecture, development practices, and deployment procedures.

## Development Environment Setup

### Prerequisites

- **Node.js** (18.0 or higher)
- **npm** or **yarn** package manager
- **PostgreSQL** (14.0 or higher)
- **MongoDB** (5.0 or higher)
- **Redis** (6.0 or higher)
- **Elasticsearch** (8.0 or higher)
- **Docker** and **Docker Compose**
- **Git** for version control

### Local Development Setup

1. **Clone Repository**

   ```bash
   git clone https://github.com/optim/backoffice-platform.git
   cd backoffice-platform
   ```

2. **Install Dependencies**

   ```bash
   # Install root dependencies
   npm install

   # Install frontend dependencies
   cd packages/frontend
   npm install

   # Install backend dependencies
   cd ../backend
   npm install

   # Install shared dependencies
   cd ../shared
   npm install
   ```

3. **Environment Configuration**

   ```bash
   # Copy environment templates
   cp .env.example .env
   cp packages/frontend/.env.example packages/frontend/.env
   cp packages/backend/.env.example packages/backend/.env
   ```

4. **Start Services with Docker**

   ```bash
   # Start required services
   docker-compose up -d postgres mongodb redis elasticsearch

   # Wait for services to be ready
   npm run wait-for-services
   ```

5. **Database Setup**

   ```bash
   # Run database migrations
   npm run migrate

   # Seed with development data
   npm run seed:dev

   # Create initial admin user
   npm run create-admin
   ```

6. **Start Development Servers**

   ```bash
   # Start all services in development mode
   npm run dev

   # Or start individually:
   # Backend API
   npm run dev:backend

   # Frontend
   npm run dev:frontend

   # Background workers
   npm run dev:workers
   ```

## Project Structure

```
backoffice-platform/
├── packages/
│   ├── frontend/                # React admin interface
│   │   ├── src/
│   │   │   ├── components/      # Reusable UI components
│   │   │   ├── pages/          # Page components
│   │   │   ├── layouts/        # Layout components
│   │   │   ├── hooks/          # Custom React hooks
│   │   │   ├── services/       # API client services
│   │   │   ├── store/          # Redux store
│   │   │   ├── utils/          # Frontend utilities
│   │   │   └── types/          # TypeScript types
│   │   ├── public/             # Static assets
│   │   └── tests/              # Frontend tests
│   ├── backend/                # Node.js API server
│   │   ├── src/
│   │   │   ├── controllers/    # Request handlers
│   │   │   ├── services/       # Business logic
│   │   │   ├── models/         # Database models
│   │   │   ├── middleware/     # Express middleware
│   │   │   ├── routes/         # API routes
│   │   │   ├── workers/        # Background jobs
│   │   │   ├── utils/          # Backend utilities
│   │   │   └── types/          # TypeScript types
│   │   ├── migrations/         # Database migrations
│   │   ├── seeds/              # Development data
│   │   └── tests/              # Backend tests
│   └── shared/                 # Shared code and types
│       ├── types/              # Common TypeScript types
│       ├── constants/          # Shared constants
│       ├── utils/              # Shared utilities
│       └── validations/        # Shared validation schemas
├── infrastructure/             # Infrastructure as code
├── docs/                      # Technical documentation
├── scripts/                   # Build and deployment scripts
└── docker-compose.yml         # Development services
```

## Architecture Overview

### Microservices Architecture

```typescript
// Service registry and communication
interface ServiceRegistry {
  userService: UserManagementService;
  supportService: SupportTicketService;
  analyticsService: AnalyticsService;
  auditService: AuditLoggingService;
  notificationService: NotificationService;
}

// Inter-service communication
export class ServiceBus {
  async publish(event: DomainEvent): Promise<void> {
    const subscribers = this.getSubscribers(event.type);
    await Promise.all(
      subscribers.map((subscriber) => subscriber.handle(event))
    );
  }

  subscribe(eventType: string, handler: EventHandler): void {
    this.subscribers.set(eventType, [
      ...(this.subscribers.get(eventType) || []),
      handler,
    ]);
  }
}
```

### Database Architecture

```sql
-- Multi-database strategy
-- PostgreSQL for relational data
CREATE DATABASE backoffice_core;
CREATE DATABASE backoffice_audit;

-- Core business entities
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  permissions JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name VARCHAR(255) NOT NULL,
  contact_email VARCHAR(255) NOT NULL,
  subscription_tier VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Support ticket system
CREATE TABLE support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customers(id),
  assigned_to UUID REFERENCES users(id),
  title VARCHAR(500) NOT NULL,
  description TEXT NOT NULL,
  priority VARCHAR(20) DEFAULT 'medium',
  status VARCHAR(50) DEFAULT 'open',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- MongoDB for flexible document storage
db.analytics_events.createIndex({ timestamp: 1, event_type: 1 })
db.system_logs.createIndex({ timestamp: 1, level: 1, service: 1 })
db.user_sessions.createIndex({ user_id: 1, expires_at: 1 })
```

### Event-Driven Architecture

```typescript
// Domain events
export interface DomainEvent {
  id: string;
  type: string;
  aggregateId: string;
  data: any;
  timestamp: Date;
  version: number;
}

// Event handlers
export class UserEventHandler {
  async handleUserCreated(event: UserCreatedEvent): Promise<void> {
    // Send welcome email
    await this.emailService.sendWelcomeEmail(event.data.email);

    // Create audit log
    await this.auditService.log({
      action: "user_created",
      userId: event.data.id,
      metadata: event.data,
    });

    // Update analytics
    await this.analyticsService.track("user_created", event.data);
  }

  async handleUserRoleChanged(event: UserRoleChangedEvent): Promise<void> {
    // Invalidate permissions cache
    await this.cacheService.invalidate(`permissions:${event.aggregateId}`);

    // Notify user of role change
    await this.notificationService.notify(event.aggregateId, {
      type: "role_changed",
      message: `Your role has been updated to ${event.data.newRole}`,
    });
  }
}
```

## Frontend Development

### Component Architecture with Ant Design

```typescript
// Admin dashboard component
import React from "react";
import { Card, Row, Col, Statistic, Table, Button } from "antd";
import {
  UserOutlined,
  TicketOutlined,
  DashboardOutlined,
} from "@ant-design/icons";
import { useQuery } from "react-query";

interface AdminDashboardProps {
  dateRange: [Date, Date];
  refreshInterval?: number;
}

export const AdminDashboard: React.FC<AdminDashboardProps> = ({
  dateRange,
  refreshInterval = 30000,
}) => {
  const { data: metrics, isLoading } = useQuery(
    ["dashboard-metrics", dateRange],
    () => analyticsApi.getDashboardMetrics(dateRange),
    { refetchInterval: refreshInterval }
  );

  const { data: recentTickets } = useQuery("recent-tickets", () =>
    supportApi.getRecentTickets(10)
  );

  return (
    <div className="admin-dashboard">
      <Row gutter={16} className="metrics-row">
        <Col span={6}>
          <Card>
            <Statistic
              title="Total Users"
              value={metrics?.totalUsers}
              prefix={<UserOutlined />}
              loading={isLoading}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="Open Tickets"
              value={metrics?.openTickets}
              prefix={<TicketOutlined />}
              loading={isLoading}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="System Health"
              value={metrics?.systemHealth}
              suffix="%"
              prefix={<DashboardOutlined />}
              loading={isLoading}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="Revenue"
              value={metrics?.revenue}
              prefix="$"
              precision={2}
              loading={isLoading}
            />
          </Card>
        </Col>
      </Row>

      <Card title="Recent Support Tickets" className="recent-tickets">
        <Table
          dataSource={recentTickets}
          columns={[
            { title: "ID", dataIndex: "id", key: "id" },
            { title: "Customer", dataIndex: "customerName", key: "customer" },
            { title: "Subject", dataIndex: "title", key: "title" },
            { title: "Priority", dataIndex: "priority", key: "priority" },
            { title: "Status", dataIndex: "status", key: "status" },
            {
              title: "Actions",
              key: "actions",
              render: (_, record) => (
                <Button type="link" href={`/support/tickets/${record.id}`}>
                  View
                </Button>
              ),
            },
          ]}
          pagination={false}
        />
      </Card>
    </div>
  );
};
```

### Advanced State Management

```typescript
// Redux store with RTK Query
import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";

// API slice for data fetching
export const backofficeApi = createApi({
  reducerPath: "backofficeApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "/api/v1/",
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token;
      if (token) {
        headers.set("authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),
  tagTypes: ["User", "Customer", "Ticket", "Analytics"],
  endpoints: (builder) => ({
    getUsers: builder.query<User[], UsersQuery>({
      query: (params) => ({
        url: "users",
        params,
      }),
      providesTags: ["User"],
    }),
    createUser: builder.mutation<User, CreateUserRequest>({
      query: (user) => ({
        url: "users",
        method: "POST",
        body: user,
      }),
      invalidatesTags: ["User"],
    }),
    getTickets: builder.query<Ticket[], TicketsQuery>({
      query: (params) => ({
        url: "support/tickets",
        params,
      }),
      providesTags: ["Ticket"],
    }),
  }),
});

// UI state slice
interface UIState {
  sidebarCollapsed: boolean;
  currentTheme: "light" | "dark";
  activeFilters: Record<string, any>;
  notifications: Notification[];
}

export const uiSlice = createSlice({
  name: "ui",
  initialState: {
    sidebarCollapsed: false,
    currentTheme: "light",
    activeFilters: {},
    notifications: [],
  } as UIState,
  reducers: {
    toggleSidebar: (state) => {
      state.sidebarCollapsed = !state.sidebarCollapsed;
    },
    setTheme: (state, action: PayloadAction<"light" | "dark">) => {
      state.currentTheme = action.payload;
    },
    setFilter: (state, action: PayloadAction<{ key: string; value: any }>) => {
      state.activeFilters[action.payload.key] = action.payload.value;
    },
    addNotification: (state, action: PayloadAction<Notification>) => {
      state.notifications.push(action.payload);
    },
  },
});
```

### Custom Hooks for Business Logic

```typescript
// Custom hook for user management
export const useUserManagement = () => {
  const [createUser, { isLoading: isCreating }] =
    backofficeApi.useCreateUserMutation();
  const [updateUser, { isLoading: isUpdating }] =
    backofficeApi.useUpdateUserMutation();
  const [deleteUser, { isLoading: isDeleting }] =
    backofficeApi.useDeleteUserMutation();

  const handleCreateUser = useCallback(
    async (userData: CreateUserRequest) => {
      try {
        const result = await createUser(userData).unwrap();
        message.success("User created successfully");
        return result;
      } catch (error) {
        message.error("Failed to create user");
        throw error;
      }
    },
    [createUser]
  );

  const handleBulkUserUpdate = useCallback(
    async (updates: BulkUserUpdate[]) => {
      const results = await Promise.allSettled(
        updates.map((update) => updateUser(update).unwrap())
      );

      const successful = results.filter((r) => r.status === "fulfilled").length;
      const failed = results.length - successful;

      if (failed > 0) {
        message.warning(`${successful} users updated, ${failed} failed`);
      } else {
        message.success(`All ${successful} users updated successfully`);
      }

      return results;
    },
    [updateUser]
  );

  return {
    createUser: handleCreateUser,
    bulkUpdate: handleBulkUserUpdate,
    isCreating,
    isUpdating,
    isDeleting,
  };
};

// Custom hook for support ticket management
export const useSupportTickets = (filters?: TicketFilters) => {
  const {
    data: tickets,
    isLoading,
    refetch,
  } = backofficeApi.useGetTicketsQuery(filters);
  const [updateTicket] = backofficeApi.useUpdateTicketMutation();
  const [assignTicket] = backofficeApi.useAssignTicketMutation();

  const handleTicketAssignment = useCallback(
    async (ticketId: string, assigneeId: string) => {
      try {
        await assignTicket({ ticketId, assigneeId }).unwrap();
        message.success("Ticket assigned successfully");
      } catch (error) {
        message.error("Failed to assign ticket");
      }
    },
    [assignTicket]
  );

  const handleBulkStatusUpdate = useCallback(
    async (ticketIds: string[], status: TicketStatus) => {
      const updates = ticketIds.map((id) => ({ id, status }));

      try {
        await Promise.all(
          updates.map((update) => updateTicket(update).unwrap())
        );
        message.success(`${ticketIds.length} tickets updated`);
        refetch();
      } catch (error) {
        message.error("Failed to update tickets");
      }
    },
    [updateTicket, refetch]
  );

  return {
    tickets,
    isLoading,
    assignTicket: handleTicketAssignment,
    bulkStatusUpdate: handleBulkStatusUpdate,
    refetch,
  };
};
```

## Backend Development

### Service Layer Architecture

```typescript
// Base service class
export abstract class BaseService {
  protected logger: Logger;
  protected cache: CacheService;
  protected eventBus: EventBus;

  constructor(logger: Logger, cache: CacheService, eventBus: EventBus) {
    this.logger = logger;
    this.cache = cache;
    this.eventBus = eventBus;
  }

  protected async withTransaction<T>(
    operation: (trx: Transaction) => Promise<T>
  ): Promise<T> {
    const trx = await this.db.transaction();
    try {
      const result = await operation(trx);
      await trx.commit();
      return result;
    } catch (error) {
      await trx.rollback();
      throw error;
    }
  }
}

// User management service
export class UserService extends BaseService {
  constructor(
    private userRepository: UserRepository,
    private roleService: RoleService,
    logger: Logger,
    cache: CacheService,
    eventBus: EventBus
  ) {
    super(logger, cache, eventBus);
  }

  async createUser(userData: CreateUserRequest): Promise<User> {
    return this.withTransaction(async (trx) => {
      // Validate user data
      const validation = await this.validateUserData(userData);
      if (!validation.isValid) {
        throw new ValidationError(validation.errors);
      }

      // Check for existing user
      const existingUser = await this.userRepository.findByEmail(
        userData.email,
        trx
      );
      if (existingUser) {
        throw new ConflictError("User already exists");
      }

      // Create user
      const user = await this.userRepository.create(
        {
          ...userData,
          id: generateId(),
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        trx
      );

      // Assign default role if not specified
      if (!userData.role) {
        await this.roleService.assignRole(user.id, "user", trx);
      }

      // Publish event
      await this.eventBus.publish(new UserCreatedEvent(user));

      // Invalidate cache
      await this.cache.invalidate("users:*");

      this.logger.info("User created", { userId: user.id, email: user.email });

      return user;
    });
  }

  async getUsersWithPagination(
    query: UsersQuery
  ): Promise<PaginatedResult<User>> {
    const cacheKey = `users:query:${JSON.stringify(query)}`;

    // Try cache first
    const cached = await this.cache.get<PaginatedResult<User>>(cacheKey);
    if (cached) {
      return cached;
    }

    // Query database
    const result = await this.userRepository.findWithPagination(query);

    // Cache result
    await this.cache.set(cacheKey, result, 300); // 5 minutes

    return result;
  }

  async updateUserRole(
    userId: string,
    newRole: string,
    updatedBy: string
  ): Promise<User> {
    return this.withTransaction(async (trx) => {
      const user = await this.userRepository.findById(userId, trx);
      if (!user) {
        throw new NotFoundError("User not found");
      }

      const oldRole = user.role;
      const updatedUser = await this.userRepository.update(
        userId,
        { role: newRole, updatedAt: new Date() },
        trx
      );

      // Publish role change event
      await this.eventBus.publish(
        new UserRoleChangedEvent({
          userId,
          oldRole,
          newRole,
          updatedBy,
        })
      );

      // Invalidate user cache
      await this.cache.invalidate(`user:${userId}`);
      await this.cache.invalidate("users:*");

      this.logger.info("User role updated", {
        userId,
        oldRole,
        newRole,
        updatedBy,
      });

      return updatedUser;
    });
  }
}
```

### Advanced Authentication & Authorization

```typescript
// JWT service with refresh tokens
export class AuthService {
  constructor(
    private userService: UserService,
    private tokenRepository: TokenRepository,
    private config: AuthConfig
  ) {}

  async authenticate(email: string, password: string): Promise<AuthResult> {
    // Validate credentials
    const user = await this.userService.validateCredentials(email, password);
    if (!user) {
      throw new AuthenticationError("Invalid credentials");
    }

    // Check if account is active
    if (user.status !== "active") {
      throw new AuthenticationError("Account is not active");
    }

    // Generate tokens
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    // Store refresh token
    await this.tokenRepository.store(refreshToken, user.id, {
      expiresAt: new Date(Date.now() + this.config.refreshTokenTTL),
      userAgent: user.lastLoginUserAgent,
      ipAddress: user.lastLoginIp,
    });

    // Update last login
    await this.userService.updateLastLogin(user.id);

    return {
      user,
      accessToken,
      refreshToken,
      expiresIn: this.config.accessTokenTTL,
    };
  }

  async refreshToken(refreshToken: string): Promise<AuthResult> {
    // Verify refresh token
    const tokenData = await this.tokenRepository.findByToken(refreshToken);
    if (!tokenData || tokenData.expiresAt < new Date()) {
      throw new AuthenticationError("Invalid refresh token");
    }

    // Get user
    const user = await this.userService.findById(tokenData.userId);
    if (!user || user.status !== "active") {
      throw new AuthenticationError("User not found or inactive");
    }

    // Generate new tokens
    const newAccessToken = this.generateAccessToken(user);
    const newRefreshToken = this.generateRefreshToken(user);

    // Replace refresh token
    await this.tokenRepository.replace(refreshToken, newRefreshToken, {
      expiresAt: new Date(Date.now() + this.config.refreshTokenTTL),
    });

    return {
      user,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      expiresIn: this.config.accessTokenTTL,
    };
  }

  private generateAccessToken(user: User): string {
    return jwt.sign(
      {
        sub: user.id,
        email: user.email,
        role: user.role,
        permissions: user.permissions,
        iat: Math.floor(Date.now() / 1000),
      },
      this.config.jwtSecret,
      {
        expiresIn: this.config.accessTokenTTL / 1000,
        issuer: "backoffice-platform",
        audience: "backoffice-api",
      }
    );
  }
}

// Permission-based authorization
export class AuthorizationService {
  constructor(private roleService: RoleService) {}

  async checkPermission(
    userId: string,
    permission: string,
    resource?: string
  ): Promise<boolean> {
    const userPermissions = await this.getUserPermissions(userId);

    // Check direct permission
    if (userPermissions.includes(permission)) {
      return true;
    }

    // Check resource-specific permission
    if (resource) {
      const resourcePermission = `${permission}:${resource}`;
      if (userPermissions.includes(resourcePermission)) {
        return true;
      }
    }

    // Check wildcard permissions
    const wildcardPermission = permission.split(":")[0] + ":*";
    if (userPermissions.includes(wildcardPermission)) {
      return true;
    }

    return false;
  }

  async getUserPermissions(userId: string): Promise<string[]> {
    const user = await this.userService.findById(userId);
    if (!user) {
      return [];
    }

    // Get role-based permissions
    const rolePermissions = await this.roleService.getRolePermissions(
      user.role
    );

    // Merge with user-specific permissions
    const allPermissions = [...rolePermissions, ...user.permissions];

    // Remove duplicates
    return [...new Set(allPermissions)];
  }
}
```

## Testing Strategy

### Comprehensive Testing Approach

```typescript
// Unit tests with comprehensive mocking
describe("UserService", () => {
  let userService: UserService;
  let mockUserRepository: jest.Mocked<UserRepository>;
  let mockRoleService: jest.Mocked<RoleService>;
  let mockEventBus: jest.Mocked<EventBus>;
  let mockCache: jest.Mocked<CacheService>;

  beforeEach(() => {
    mockUserRepository = createMockUserRepository();
    mockRoleService = createMockRoleService();
    mockEventBus = createMockEventBus();
    mockCache = createMockCacheService();

    userService = new UserService(
      mockUserRepository,
      mockRoleService,
      createMockLogger(),
      mockCache,
      mockEventBus
    );
  });

  describe("createUser", () => {
    const validUserData = {
      email: "test@example.com",
      name: "Test User",
      role: "user",
    };

    it("should create a user successfully", async () => {
      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.create.mockResolvedValue({
        id: "user-1",
        ...validUserData,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const result = await userService.createUser(validUserData);

      expect(result).toEqual(expect.objectContaining(validUserData));
      expect(mockEventBus.publish).toHaveBeenCalledWith(
        expect.any(UserCreatedEvent)
      );
      expect(mockCache.invalidate).toHaveBeenCalledWith("users:*");
    });

    it("should throw error if user already exists", async () => {
      mockUserRepository.findByEmail.mockResolvedValue({
        id: "existing-user",
        email: validUserData.email,
      } as User);

      await expect(userService.createUser(validUserData)).rejects.toThrow(
        ConflictError
      );
    });
  });
});

// Integration tests
describe("User API Integration", () => {
  let app: Application;
  let testDb: TestDatabase;
  let authToken: string;

  beforeAll(async () => {
    testDb = await createTestDatabase();
    app = await createTestApp(testDb);
    authToken = await createTestAuthToken("admin");
  });

  afterAll(async () => {
    await testDb.cleanup();
  });

  beforeEach(async () => {
    await testDb.reset();
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

      // Verify user was created in database
      const createdUser = await testDb.users.findByEmail(userData.email);
      expect(createdUser).toBeTruthy();
    });

    it("should return 409 for duplicate email", async () => {
      // Create user first
      await testDb.users.create({
        email: "duplicate@example.com",
        name: "Existing User",
        role: "user",
      });

      const response = await request(app)
        .post("/api/users")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          email: "duplicate@example.com",
          name: "New User",
          role: "user",
        })
        .expect(409);

      expect(response.body.error).toContain("already exists");
    });
  });
});

// End-to-end tests
describe("User Management E2E", () => {
  let page: Page;

  beforeAll(async () => {
    page = await browser.newPage();
    await page.goto("http://localhost:3000");
    await loginAsAdmin(page);
  });

  afterAll(async () => {
    await page.close();
  });

  it("should create a new user through UI", async () => {
    // Navigate to users page
    await page.click('[data-testid="nav-users"]');
    await page.waitForSelector('[data-testid="users-table"]');

    // Click create user button
    await page.click('[data-testid="create-user-btn"]');
    await page.waitForSelector('[data-testid="create-user-form"]');

    // Fill out form
    await page.fill('[data-testid="user-email"]', "e2e-test@example.com");
    await page.fill('[data-testid="user-name"]', "E2E Test User");
    await page.selectOption('[data-testid="user-role"]', "user");

    // Submit form
    await page.click('[data-testid="submit-user"]');

    // Verify success message
    await page.waitForSelector('[data-testid="success-message"]');

    // Verify user appears in table
    await page.waitForSelector(
      '[data-testid="users-table"] td:has-text("e2e-test@example.com")'
    );
  });
});
```

## Performance Optimization

### Database Performance

```typescript
// Query optimization with proper indexing
export class UserRepository {
  async findUsersWithComplexFilters(filters: UserFilters): Promise<User[]> {
    let query = this.db
      .select("users.*")
      .from("users")
      .leftJoin("user_roles", "users.id", "user_roles.user_id")
      .leftJoin("roles", "user_roles.role_id", "roles.id");

    // Apply filters with proper indexing
    if (filters.search) {
      query = query.whereRaw(
        `to_tsvector('english', users.name || ' ' || users.email) @@ plainto_tsquery('english', ?)`,
        [filters.search]
      );
    }

    if (filters.role) {
      query = query.where("roles.name", filters.role);
    }

    if (filters.status) {
      query = query.where("users.status", filters.status);
    }

    if (filters.createdAfter) {
      query = query.where("users.created_at", ">=", filters.createdAfter);
    }

    // Optimize with proper ordering and limits
    return query
      .orderBy("users.created_at", "desc")
      .limit(filters.limit || 50)
      .offset(filters.offset || 0);
  }
}

// Caching strategy for frequently accessed data
export class CachedUserService extends UserService {
  async getUserById(id: string): Promise<User | null> {
    const cacheKey = `user:${id}`;

    // Try cache first
    const cached = await this.cache.get<User>(cacheKey);
    if (cached) {
      return cached;
    }

    // Fetch from database
    const user = await this.userRepository.findById(id);
    if (user) {
      // Cache for 10 minutes
      await this.cache.set(cacheKey, user, 600);
    }

    return user;
  }

  async invalidateUserCache(userId: string): Promise<void> {
    await Promise.all([
      this.cache.invalidate(`user:${userId}`),
      this.cache.invalidate(`user:permissions:${userId}`),
      this.cache.invalidate("users:*"), // Invalidate list caches
    ]);
  }
}
```

### Frontend Performance

```typescript
// Component optimization with React.memo and useMemo
export const UserList = React.memo<UserListProps>(
  ({ users, onUserSelect, filters }) => {
    // Memoize expensive calculations
    const filteredUsers = useMemo(() => {
      return users
        .filter((user) => {
          if (filters.search) {
            const searchLower = filters.search.toLowerCase();
            return (
              user.name.toLowerCase().includes(searchLower) ||
              user.email.toLowerCase().includes(searchLower)
            );
          }
          return true;
        })
        .sort((a, b) => a.name.localeCompare(b.name));
    }, [users, filters.search]);

    // Virtualized list for large datasets
    const rowRenderer = useCallback(
      ({ index, key, style }) => {
        const user = filteredUsers[index];
        return (
          <div key={key} style={style}>
            <UserCard user={user} onSelect={onUserSelect} />
          </div>
        );
      },
      [filteredUsers, onUserSelect]
    );

    return (
      <AutoSizer>
        {({ height, width }) => (
          <List
            height={height}
            width={width}
            rowCount={filteredUsers.length}
            rowHeight={120}
            rowRenderer={rowRenderer}
          />
        )}
      </AutoSizer>
    );
  }
);

// Optimized data fetching with React Query
export const useOptimizedUsers = (filters: UserFilters) => {
  return useQuery(["users", filters], () => userApi.getUsers(filters), {
    // Stale time: consider data fresh for 5 minutes
    staleTime: 5 * 60 * 1000,

    // Cache time: keep in cache for 30 minutes
    cacheTime: 30 * 60 * 1000,

    // Background refetch on window focus
    refetchOnWindowFocus: false,

    // Retry failed requests 3 times
    retry: 3,

    // Enable if query key changes
    keepPreviousData: true,

    // Transform data
    select: useCallback((data: ApiResponse<User[]>) => {
      return data.data.map((user) => ({
        ...user,
        displayName: `${user.name} (${user.email})`,
      }));
    }, []),
  });
};
```

## Deployment & DevOps

### Docker Multi-stage Build

```dockerfile
# Backend Dockerfile with multi-stage build
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
COPY packages/backend/package*.json ./packages/backend/
COPY packages/shared/package*.json ./packages/shared/
RUN npm ci --only=production

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
COPY packages/ ./packages/
RUN npm ci
RUN npm run build

FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=builder /app/packages/backend/dist ./dist
COPY --from=builder /app/packages/shared/dist ./shared

USER nodejs

EXPOSE 3000
ENV NODE_ENV production

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "dist/index.js"]
```

### Kubernetes Deployment

```yaml
# Complete Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backoffice-backend
  labels:
    app: backoffice-backend
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: backoffice-backend
  template:
    metadata:
      labels:
        app: backoffice-backend
        version: v1
    spec:
      containers:
        - name: backend
          image: optim/backoffice-backend:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: production
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: database-secret
                  key: url
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: redis-secret
                  key: url
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: auth-secret
                  key: jwt-secret
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 60
            periodSeconds: 30
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
          volumeMounts:
            - name: config
              mountPath: /app/config
              readOnly: true
      volumes:
        - name: config
          configMap:
            name: backoffice-config
      imagePullSecrets:
        - name: registry-secret
---
apiVersion: v1
kind: Service
metadata:
  name: backoffice-backend-service
spec:
  selector:
    app: backoffice-backend
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
  type: ClusterIP
```

## Monitoring & Observability

### Comprehensive Logging

```typescript
// Structured logging with correlation IDs
export class StructuredLogger {
  constructor(private serviceName: string) {}

  info(message: string, context: LogContext = {}): void {
    this.log("info", message, context);
  }

  error(message: string, error: Error, context: LogContext = {}): void {
    this.log("error", message, {
      ...context,
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
    });
  }

  private log(level: LogLevel, message: string, context: LogContext): void {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      service: this.serviceName,
      correlationId: context.correlationId || generateCorrelationId(),
      userId: context.userId,
      requestId: context.requestId,
      ...context,
    };

    console.log(JSON.stringify(logEntry));
  }
}

// Request correlation middleware
export const correlationMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const correlationId =
    (req.headers["x-correlation-id"] as string) || generateCorrelationId();

  req.correlationId = correlationId;
  res.setHeader("x-correlation-id", correlationId);

  // Add to async local storage for deeper correlation
  correlationStorage.run(correlationId, () => {
    next();
  });
};
```

### Performance Monitoring

```typescript
// Performance metrics collection
export class MetricsCollector {
  private metrics = new Map<string, number>();

  recordDuration(name: string, duration: number): void {
    this.metrics.set(`${name}_duration`, duration);
  }

  increment(name: string, value: number = 1): void {
    const current = this.metrics.get(name) || 0;
    this.metrics.set(name, current + value);
  }

  gauge(name: string, value: number): void {
    this.metrics.set(name, value);
  }

  getMetrics(): Record<string, number> {
    return Object.fromEntries(this.metrics);
  }
}

// Performance monitoring middleware
export const performanceMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const start = Date.now();

  res.on("finish", () => {
    const duration = Date.now() - start;

    metricsCollector.recordDuration("http_request_duration", duration);
    metricsCollector.increment(`http_requests_total_${res.statusCode}`);

    if (duration > 1000) {
      logger.warn("Slow request detected", {
        method: req.method,
        url: req.url,
        duration,
        statusCode: res.statusCode,
      });
    }
  });

  next();
};
```

---

_For development questions or support, contact the Backoffice Development Team at backoffice-dev@optim.com_
