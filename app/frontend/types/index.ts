export type FlashData = {
  notice?: string
  alert?: string
}

export type User = {
  id: number
  full_name: string
  email_address: string
  role: 'user' | 'admin'
  avatar_source: string
}

export type SharedProps = {
  auth: {
    user: User | null
  }
}

export type SessionDP = SharedProps & {
  flash: FlashData
}

export type Pagination = {
  page: number
  pages: number
  count: number
  items: number
  prev: number | null
  next: number | null
}

export type UsersOverview = {
  total_users: number
  by_role: Record<string, number>
}

export type AdminPageUrls = {
  dashboard_url: string
  users_url: string
  imports_url: string
}

export type ImportStatus = 'pending' | 'processing' | 'completed' | 'failed'

export type AdminImport = {
  id: number
  file_name: string | null
  status: ImportStatus
  status_human: string
  total_rows: number
  processed_rows: number
  failed_rows: number
  progress: number
  finished_at: string | null
  error_message: string | null
  created_at: string | null
}

export type AdminImportListItem = AdminImport & {
  show_url: string
}

export type AdminUser = User & {
  edit_url: string
  toggle_url: string
  delete_url: string
}

export type UserFormData = {
  full_name?: string
  email_address?: string
  avatar_url?: string
  role?: string
}
