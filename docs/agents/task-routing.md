# Task Routing

Use this routing table when assigning agent work.

| Work Type | Lead Agent | Required Review |
| --- | --- | --- |
| Roadmap, milestone, scope | PM | BA, SA, QA |
| User stories, rules, acceptance criteria | BA | PM, QA, UX/UI |
| Navigation, screens, interaction design | UX/UI | BA, Dev, QA |
| Flutter structure, provider/repository patterns | SA | Dev, QA |
| Long-term platform or integration direction | EA | PM, SA, Infra |
| Firestore schema or security rules | DBA | Data, Security, SA |
| Ranking, collection, analytics, seed data | Data | BA, DBA, QA |
| Feature implementation | Dev | SA, QA, UX/UI |
| Local setup, Firebase config, platform setup | Infra | DevOps, Security |
| CI/CD, release workflow, quality gates | DevOps | QA, Infra |
| Test plan, regression, release sign-off | QA | PM, BA, Dev |
| Location privacy, secrets, abuse risk | Security | PM, DBA, Infra |

## Default Feature Team

For normal MVP feature work, use:

- PM for scope.
- BA for acceptance criteria.
- UX/UI for flow.
- SA for implementation direction.
- Data or DBA when data changes.
- Dev for code.
- QA for verification.

## When To Split Into Parallel Agents

Split work only when file ownership and outputs are clear.

- PM and BA can work on scope/story docs while SA audits architecture.
- UX/UI can draft flow while Data/DBA draft schema.
- Dev can implement UI only after BA/UX/UI acceptance criteria are stable.
- QA can build a checklist while Dev implements.

Do not run multiple Dev agents against the same files unless the write scopes are explicitly disjoint.
