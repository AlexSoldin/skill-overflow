# Coolset Ecosystem — Repo Registry

Single source of truth for the Coolset platform architecture. Used by the planner to identify affected repos, trace cross-service dependencies, and generate accurate implementation plans.

## Backend Services

| Repo | Service | Port | Python | Framework | App Module | Domain |
|------|---------|------|--------|-----------|------------|--------|
| cs-api | cs-api | 8000 | 3.11 | Django/DRF | `gc_api` | Emissions, companies, transactions, users, auth |
| data-room-api | data-room-api | 8001 | 3.11 | Django/DRF | `data_room` | Surveys, submissions, data collection |
| cs-pulse | cs-pulse | 8002 | 3.11 | Django/DRF | `pulse` | Activity tracking, notifications |
| cs-scranton | cs-scranton | 8003 | 3.13 | Django/DRF | `scranton` | Supply chain, orders, products, suppliers |
| cs-eunice | — (celery only) | — | 3.11 | Celery | `eunice` | ML, classification, async processing |

## Shared Libraries

| Repo | Purpose | Used By |
|------|---------|---------|
| cs-common | Auth, tchu-tchu events, rules engine, geo utils, websockets | All backend services |

## Frontend Applications

| Repo | Framework | Package Manager | Key Modules |
|------|-----------|-----------------|-------------|
| coolset-react-app | React 19 / Vite / TypeScript | pnpm | Emissions, SupplyChain, Surveys, Companies, Compliance, Settings |
| data-room-react-app | React 18 / Vite / TypeScript | pnpm | Survey editor, data room viewer |
| cs-ui | React / TypeScript | pnpm | Shared component library (buttons, forms, tables, modals) |
| data-room-package | React / TypeScript | pnpm | Shared data room components |

## Infrastructure

| Repo | Purpose |
|------|---------|
| terraform | Cloud infrastructure (GCP, CloudSQL, GKE, Cloud Run) |
| cloud-functions | GCP Cloud Functions (webhooks, scheduled jobs) |
| service-orchestration | Docker Compose, local dev environment, CI orchestration |

## Domain → Repo Mapping

| Domain | Primary Repo | Secondary Repos | Frontend Module |
|--------|-------------|-----------------|-----------------|
| Emissions | cs-api | cs-eunice (calculations) | `coolset-react-app/Emissions` |
| Companies | cs-api | — | `coolset-react-app/Companies` |
| Transactions | cs-api | cs-eunice (classification) | `coolset-react-app/Emissions` |
| Users & Auth | cs-api | cs-common (auth middleware) | `coolset-react-app/Settings` |
| Surveys | data-room-api | — | `coolset-react-app/Surveys`, `data-room-react-app` |
| Submissions | data-room-api | — | `data-room-react-app` |
| Activity | cs-pulse | cs-api (triggers) | `coolset-react-app` (notifications) |
| Supply Chain | cs-scranton | cs-eunice (product matching) | `coolset-react-app/SupplyChain` |
| Orders | cs-scranton | — | `coolset-react-app/SupplyChain` |
| Compliance | cs-api | data-room-api (data points) | `coolset-react-app/Compliance` |

## Event System (tchu-tchu)

Cross-service communication uses the tchu-tchu pub/sub system via RabbitMQ, defined in cs-common.

### Event Namespaces

| Namespace | Location | Publisher | Subscribers |
|-----------|----------|-----------|-------------|
| `coolset_events` | `cs-common/tchu_tchu/events/coolset_events.py` | cs-api | cs-pulse, cs-scranton, cs-eunice |
| `data_room_events` | `cs-common/tchu_tchu/events/data_room_events.py` | data-room-api | cs-api, cs-pulse |
| `pulse_events` | `cs-common/tchu_tchu/events/pulse_events.py` | cs-pulse | cs-api |
| `scranton_events` | `cs-common/tchu_tchu/events/scranton_events.py` | cs-scranton | cs-api, cs-eunice |
| `global_events` | `cs-common/tchu_tchu/events/global_events.py` | any service | all services |

### Event Pattern

Publishers emit events via `tchu_tchu.publish(event_name, payload)`. Subscribers register handlers in their `tchu_tchu_handlers.py` or equivalent module. Events are routed through RabbitMQ exchanges.

## Code Patterns

### Backend
- **Repository pattern**: Data access via `repositories/` directory, not direct ORM in views
- **View structure**: `views/` → `serializers/` → `repositories/` → models
- **Test conventions**: `pytest` with fixtures in `conftest.py`, factory-based test data
- **Migrations**: Django migrations per app, coordinate across services for shared models
- **Settings**: `settings/base.py`, `settings/local.py`, `settings/production.py`

### Frontend
- **Module structure**: `src/modules/<domain>/` with pages, components, hooks, api subdirs
- **Generated types**: OpenAPI → TypeScript types via code generation
- **Data fetching**: React Query (`@tanstack/react-query`) with generated API clients
- **State management**: React Query for server state, React context for UI state
- **Routing**: React Router with lazy-loaded module routes

### Cross-Service
- **API communication**: Services call each other via internal HTTP APIs
- **Shared auth**: JWT tokens validated by cs-common middleware in each service
- **Feature flags**: Managed centrally, checked per-service
