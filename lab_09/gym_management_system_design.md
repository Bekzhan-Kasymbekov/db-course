# Database Design Task: Gym & Fitness Tracking System

## 1. Conceptual Design

### Entities
- Members
- Memberships
- Trainers
- Workout programs
- Payments
- Log
- Gym session
- Exercise

### Relationships
- Memberships have members (one-to-many)
- Members make payments (one-to-many)
- Members attend gym sessions (one-to-many)
- Members follow workout programs (many-to-many)

- Trainers train members(many-to-many)
- Trainers create workout programs(one-to-many)

- Workout programs have exercises(many-to-many)

- Members write logs(one-to-many)
