# Taiga Class Diagram

This document presents the class diagram showing the core entities and their relationships in the Taiga system.

```mermaid
classDiagram
    class BaseModel {
        +id: UUID
    }
    
    class User {
        +username: str
        +email: str
        +full_name: str
        +color: int
        +is_active: bool
        +is_superuser: bool
        +accepted_terms: bool
        +lang: str
        +date_joined: datetime
        +date_verification: datetime
        +get_short_name()
        +get_full_name()
        +has_perm(perm: str)
    }

    class Workspace {
        +name: str
        +color: int
        +created_at: datetime
        +modified_at: datetime
        +slug: str
    }

    class Project {
        +name: str
        +description: str
        +color: int
        +logo: File
        +public_permissions: Array
        +created_at: datetime
        +modified_at: datetime
        +slug: str
        +public_user_can_view: bool
        +anon_user_can_view: bool
    }

    class ProjectTemplate {
        +name: str
        +slug: str
        +roles: JSON
        +workflows: JSON
        +workflow_statuses: JSON
    }

    class WorkspaceMembership {
        +user: User
        +workspace: Workspace
        +created_at: datetime
    }

    class ProjectMembership {
        +user: User
        +project: Project
        +role: str
        +created_at: datetime
    }

    class AuthData {
        +user: User
        +key: str
        +value: str
        +extra: JSON
    }

    BaseModel <|-- User
    BaseModel <|-- Workspace
    BaseModel <|-- Project
    BaseModel <|-- ProjectTemplate
    BaseModel <|-- WorkspaceMembership
    BaseModel <|-- ProjectMembership
    BaseModel <|-- AuthData

    User "1" -- "*" AuthData
    User "1" -- "*" WorkspaceMembership
    User "1" -- "*" ProjectMembership
    Workspace "1" -- "*" WorkspaceMembership
    Workspace "1" -- "*" Project
    Project "1" -- "*" ProjectMembership

```

## Key Relationships

1. **User - Workspace**
   - Users can be members of multiple workspaces through WorkspaceMembership
   - Each workspace can have multiple users as members

2. **Workspace - Project**
   - A workspace can contain multiple projects
   - Each project belongs to exactly one workspace

3. **User - Project**
   - Users can be members of multiple projects through ProjectMembership
   - Each project can have multiple users as members
   - Project membership includes role information

4. **User - AuthData**
   - Users can have multiple authentication data entries
   - Each auth data entry belongs to exactly one user

5. **Project - ProjectTemplate**
   - Projects can be created from templates
   - Templates define roles, workflows, and statuses

## Inheritance

All main entities inherit from BaseModel, which provides:
- UUID primary key
- Common database functionality
- Basic model operations

## Additional Features

1. **Timestamps**
   - Workspace and Project include creation and modification timestamps
   - Memberships track creation time

2. **Slugs**
   - Workspace, Project, and ProjectTemplate maintain slugified versions of their names
   - Used for URLs and unique identification

3. **Permissions**
   - Projects maintain public permission settings
   - Users have superuser status and permission checks
   - Project memberships include role-based permissions

4. **Metadata**
   - Projects store logos and colors
   - Users maintain language preferences and verification status
   - Templates store workflow configurations as JSON