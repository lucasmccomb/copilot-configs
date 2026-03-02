---
name: 'React TypeScript Standards'
description: 'Coding conventions for React TypeScript files'
applyTo: '**/*.{tsx,ts}'
---

## Component Patterns

- Always use functional components with TypeScript interfaces for props
- Never use class components
- Export components as named exports, not default exports

```typescript
interface ComponentProps {
  // Define props with explicit types
}

export function Component({ prop1, prop2 }: ComponentProps) {
  return <div className="container">...</div>;
}
```

## Fast Refresh (Vite Projects)

NEVER export both React components and non-components from the same file:
- Components in their own files (only component exports)
- Hooks in separate files
- Utilities/constants in separate files

## Imports

Use path aliases:
- `@/` -> `src/`
- `@components/` -> `src/components/`
- `@hooks/` -> `src/hooks/`
- `@services/` -> `src/services/`
- `@types/` -> `src/types/`

## Error Handling

- Use error boundaries for major sections
- Show toast notifications for user feedback
- Validate forms before submit with inline errors
- Handle loading and error states in data fetching

## Security

- Sanitize user input with DOMPurify before rendering HTML
- Validate image uploads (MIME type, size limits)
- Never render user input without sanitization
