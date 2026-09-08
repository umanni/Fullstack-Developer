export type FlashData = {
  notice?: string
  alert?: string
}

export type Role = 'user' | 'admin'

export type User = {
  id: number
  full_name: string
  email: string
  role: Role
  avatar_url: string | null
  created_at: string
}

export type UserStatistics = {
  total: number
  by_role: Record<Role, number>
  generated_at: string
}

export type ImportStatus =
  'pending' | 'processing' | 'completed' | 'completed_with_errors' | 'failed'

export type UserImport = {
  id: number
  status: ImportStatus
  file_name: string | null
  total_rows: number
  processed_rows: number
  successful_rows: number
  failed_rows: number
  progress_percentage: number
  failure_message: string | null
  uploaded_by: string
  created_at: string
  started_at: string | null
  finished_at: string | null
  row_errors: Array<{
    row_number: number
    email: string | null
    message: string
  }>
}

export type Pagination = {
  page: number
  pages: number
  count: number
  limit: number
  previous: number | null
  next: number | null
}

export type ErrorValue = string | string[] | undefined

export type SharedProps = {
  auth: { user: User | null }
}
