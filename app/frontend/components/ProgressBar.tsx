export function ProgressBar({
  value,
  label,
}: {
  value: number
  label?: string
}) {
  const percentage = Math.min(Math.max(value, 0), 100)

  return (
    <div>
      {label && (
        <div className="mb-2 flex items-center justify-between text-sm">
          <span className="font-medium text-slate-700">{label}</span>
          <span className="tabular-nums text-slate-500">{percentage}%</span>
        </div>
      )}
      <div
        aria-label={label ?? 'Progress'}
        aria-valuemax={100}
        aria-valuemin={0}
        aria-valuenow={percentage}
        className="h-2.5 overflow-hidden rounded-full bg-slate-200"
        role="progressbar"
      >
        <div
          className="h-full rounded-full bg-brand-600 transition-[width] duration-500"
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  )
}
