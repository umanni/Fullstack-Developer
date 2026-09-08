import { classNames } from '@/lib/class-names'
import { initials } from '@/lib/formatters'

const sizes = {
  sm: 'size-9 text-xs',
  md: 'size-11 text-sm',
  lg: 'size-14 text-base',
  xl: 'size-24 text-2xl',
}

export function Avatar({
  name,
  src,
  size = 'md',
}: {
  name: string
  src: string | null
  size?: 'sm' | 'md' | 'lg' | 'xl'
}) {
  return src ? (
    <img
      alt={`${name}'s avatar`}
      className={classNames(
        'shrink-0 rounded-full object-cover ring-2 ring-white',
        sizes[size],
      )}
      src={src}
    />
  ) : (
    <span
      aria-label={`${name}'s initials`}
      className={classNames(
        'grid shrink-0 place-items-center rounded-full bg-brand-100 font-bold text-brand-800 ring-2 ring-white',
        sizes[size],
      )}
    >
      {initials(name)}
    </span>
  )
}
