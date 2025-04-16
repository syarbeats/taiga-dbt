# Taiga Sequence Diagrams

This document presents the key interaction sequences between different components in the Taiga system.

## 1. Project Creation Sequence

```mermaid
sequenceDiagram
    actor User
    participant API
    participant ProjectService
    participant WorkflowService
    participant NotificationService
    participant DB

    User->>API: POST /projects
    API->>ProjectService: create_project(data)
    ProjectService->>DB: save project
    ProjectService->>WorkflowService: create_default_workflows()
    WorkflowService->>DB: save workflows
    ProjectService->>NotificationService: notify_workspace_members()
    NotificationService-->>User: workspace notification
    API-->>User: project details
```

## 2. Story Management Sequence

```mermaid
sequenceDiagram
    actor User
    participant API
    participant StoryService
    participant WorkflowService
    participant NotificationService
    participant EventManager

    User->>API: POST /projects/{id}/stories
    API->>StoryService: create_story(data)
    StoryService->>WorkflowService: validate_status()
    WorkflowService-->>StoryService: status valid
    StoryService->>DB: save story
    StoryService->>NotificationService: notify_project_members()
    NotificationService->>EventManager: emit story_created
    EventManager-->>User: real-time update
    API-->>User: story details

    Note over User,API: Story Update Flow
    User->>API: PATCH /projects/{id}/stories/{ref}
    API->>StoryService: update_story(data)
    StoryService->>DB: check version
    DB-->>StoryService: version ok
    StoryService->>DB: save changes
    StoryService->>NotificationService: notify_story_watchers()
    NotificationService->>EventManager: emit story_updated
    EventManager-->>User: real-time update
    API-->>User: updated story
```

## 3. Authentication Flow

```mermaid
sequenceDiagram
    actor User
    participant API
    participant AuthService
    participant TokenService
    participant UserService

    User->>API: POST /auth/token
    API->>AuthService: authenticate(credentials)
    AuthService->>UserService: validate_user()
    UserService-->>AuthService: user valid
    AuthService->>TokenService: generate_token()
    TokenService-->>AuthService: access token
    AuthService-->>User: auth token

    Note over User,API: Using Auth Token
    User->>API: Request with token
    API->>AuthService: validate_token()
    AuthService->>TokenService: verify_token()
    TokenService-->>AuthService: token valid
    AuthService-->>API: user context
    API-->>User: requested resource
```

## 4. Workspace Collaboration Sequence

```mermaid
sequenceDiagram
    actor Admin
    actor Member
    participant API
    participant WorkspaceService
    participant InvitationService
    participant NotificationService
    participant EmailService

    Admin->>API: POST /workspaces/{id}/invitations
    API->>WorkspaceService: validate_permissions()
    WorkspaceService-->>API: admin authorized
    API->>InvitationService: create_invitation()
    InvitationService->>DB: save invitation
    InvitationService->>EmailService: send_invitation_email()
    EmailService-->>Member: invitation email
    
    Member->>API: POST /workspaces/invitations/{token}
    API->>InvitationService: accept_invitation()
    InvitationService->>WorkspaceService: add_member()
    WorkspaceService->>DB: save membership
    WorkspaceService->>NotificationService: notify_workspace_members()
    NotificationService-->>Admin: member joined
    API-->>Member: workspace access
```

## Key Interaction Patterns

1. **Authentication & Authorization**
   - Token-based authentication
   - Permission validation before actions
   - Role-based access control

2. **Real-time Updates**
   - Event-driven notifications
   - WebSocket connections for live updates
   - Email notifications for important events

3. **Data Consistency**
   - Version checking for updates
   - Transaction management
   - Optimistic concurrency control

4. **Service Communication**
   - Service-to-service interactions
   - Event propagation
   - Asynchronous notifications

## Important Notes

1. **Error Handling**
   - All interactions include error handling
   - Proper error responses to clients
   - Rollback mechanisms for failed operations

2. **Performance Considerations**
   - Asynchronous operations where possible
   - Efficient database queries
   - Caching of frequently accessed data

3. **Security Measures**
   - Token validation on every request
   - Permission checks at service level
   - Secure communication channels