# Taiga ER Diagram

This document presents the Entity-Relationship diagram showing the database structure and relationships in the Taiga system.

```mermaid
erDiagram
    User ||--o{ AuthData : has
    User ||--o{ WorkspaceMembership : belongs_to
    User ||--o{ ProjectMembership : belongs_to
    User ||--o{ StoryAssignment : assigned_to

    Workspace ||--o{ WorkspaceMembership : contains
    Workspace ||--o{ Project : contains

    Project ||--o{ ProjectMembership : has
    Project ||--o{ Workflow : has
    Project ||--o{ Story : contains

    Workflow ||--o{ WorkflowStatus : has
    Workflow ||--o{ Story : manages

    Story ||--o{ StoryAssignment : has
    Story ||--o{ Attachment : has
    Story ||--o{ Comment : has
    Story ||--o{ MediaFile : has
    Story }|--|| WorkflowStatus : current_status

    User {
        UUID id PK
        string username UK
        string email UK
        string full_name
        int color
        boolean is_active
        boolean is_superuser
        boolean accepted_terms
        string lang
        datetime date_joined
        datetime date_verification
    }

    Workspace {
        UUID id PK
        string name
        int color
        datetime created_at
        datetime modified_at
    }

    Project {
        UUID id PK
        string name
        string description
        int color
        string logo
        array public_permissions
        UUID workspace_id FK
        datetime created_at
        datetime modified_at
    }

    WorkspaceMembership {
        UUID id PK
        UUID user_id FK
        UUID workspace_id FK
        datetime created_at
    }

    ProjectMembership {
        UUID id PK
        UUID user_id FK
        UUID project_id FK
        string role
        datetime created_at
    }

    Workflow {
        UUID id PK
        string name
        string slug UK
        decimal order
        UUID project_id FK
    }

    WorkflowStatus {
        UUID id PK
        string name
        int color
        decimal order
        UUID workflow_id FK
    }

    Story {
        UUID id PK
        string title
        text description
        decimal order
        UUID project_id FK
        UUID workflow_id FK
        UUID status_id FK
        datetime created_at
        datetime title_updated_at
        datetime description_updated_at
        int version
    }

    StoryAssignment {
        UUID id PK
        UUID story_id FK
        UUID user_id FK
        datetime created_at
    }

    AuthData {
        UUID id PK
        UUID user_id FK
        string key
        string value
        json extra
    }

    Comment {
        UUID id PK
        UUID story_id FK
        text content
        datetime created_at
    }

    Attachment {
        UUID id PK
        UUID story_id FK
        string file
        string name
        datetime created_at
    }

    MediaFile {
        UUID id PK
        UUID story_id FK
        string file
        string name
        datetime created_at
    }
```

## Key Relationships

1. **User Relationships**
   - Users can belong to multiple workspaces through WorkspaceMembership
   - Users can belong to multiple projects through ProjectMembership
   - Users can be assigned to multiple stories through StoryAssignment
   - Users can have multiple authentication data entries

2. **Workspace Relationships**
   - Workspaces contain multiple projects
   - Workspaces have multiple members through WorkspaceMembership

3. **Project Relationships**
   - Projects belong to one workspace
   - Projects have multiple workflows
   - Projects contain multiple stories
   - Projects have multiple members through ProjectMembership

4. **Story Relationships**
   - Stories belong to one project
   - Stories are managed by one workflow
   - Stories have one current status
   - Stories can have multiple assignees
   - Stories can have multiple attachments, comments, and media files

5. **Workflow Relationships**
   - Workflows belong to one project
   - Workflows contain multiple statuses
   - Workflows manage multiple stories

## Important Notes

1. **Primary Keys**
   - All entities use UUID as their primary key

2. **Unique Constraints**
   - Username and email are unique for Users
   - Workflow slugs are unique within a project
   - WorkflowStatus IDs are unique within a workflow

3. **Timestamps**
   - Most entities track creation time
   - Some entities also track modification time
   - Stories track separate update times for title and description

4. **Versioning**
   - Stories implement versioning for optimistic concurrency control

5. **File Storage**
   - Projects can have logos
   - Stories can have attachments and media files
   - Files are stored with obfuscated paths

6. **Ordering**
   - Workflows, WorkflowStatuses, and Stories maintain order fields
   - Most entities have default ordering by name or creation time