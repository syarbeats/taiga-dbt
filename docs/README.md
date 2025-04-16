# Taiga System Documentation

This documentation provides a comprehensive technical overview of the Taiga project management system through various UML diagrams.

## Table of Contents

1. [Class Diagram](class-diagram.md)
   - Shows the object-oriented structure of the system
   - Details class relationships and inheritance
   - Documents key methods and attributes
   - Explains system architecture patterns

2. [Entity-Relationship Diagram](er-diagram.md)
   - Illustrates the database schema
   - Shows relationships between entities
   - Details data attributes and constraints
   - Documents database design patterns

3. [Activity Diagrams](activity-diagram.md)
   - Demonstrates key user workflows
   - Shows system processes
   - Illustrates decision points
   - Documents business logic flows

4. [Sequence Diagrams](sequence-diagram.md)
   - Shows component interactions
   - Details authentication flows
   - Illustrates data flow between services
   - Documents system communication patterns

## System Overview

Taiga is a project management system built with:
- Backend: Python (FastAPI, Django)
- Frontend: Angular/TypeScript
- Database: PostgreSQL
- Real-time: WebSocket for live updates
- Authentication: Token-based auth

### Key Components

1. **Workspace Management**
   - Organization of projects
   - Team collaboration
   - Member management

2. **Project Management**
   - Project configuration
   - Workflow customization
   - Team coordination

3. **Story Tracking**
   - Task management
   - Status workflows
   - Assignment handling

4. **Collaboration Features**
   - Comments and discussions
   - File attachments
   - Real-time notifications

## Architecture Highlights

1. **Service-Oriented Architecture**
   - Modular services
   - Clear separation of concerns
   - Scalable design

2. **Event-Driven System**
   - Real-time updates
   - Asynchronous operations
   - WebSocket integration

3. **Security Model**
   - Role-based access control
   - Token-based authentication
   - Permission management

4. **Data Management**
   - Optimistic concurrency
   - Version control
   - Efficient querying

## Using This Documentation

- Start with the Class Diagram for a high-level system overview
- Use the ER Diagram to understand data relationships
- Review Activity Diagrams to understand user workflows
- Consult Sequence Diagrams for detailed interactions

Each diagram provides different perspectives on the system, helping to understand both the static structure and dynamic behavior of Taiga.