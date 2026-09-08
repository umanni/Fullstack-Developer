module.exports = {
  clearMocks: true,
  collectCoverageFrom: [
    'app/frontend/components/**/*.{ts,tsx}',
    'app/frontend/hooks/**/*.{ts,tsx}',
    'app/frontend/lib/**/*.{ts,tsx}',
    '!app/frontend/**/*.d.ts',
  ],
  coverageDirectory: 'coverage/frontend',
  coveragePathIgnorePatterns: ['/node_modules/'],
  coverageThreshold: {
    global: {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90,
    },
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/app/frontend/$1',
  },
  setupFilesAfterEnv: ['<rootDir>/app/frontend/test/setup.ts'],
  testEnvironment: 'jsdom',
  testMatch: ['<rootDir>/app/frontend/**/*.test.{ts,tsx}'],
  transform: {
    '^.+\\.(ts|tsx)$': 'babel-jest',
  },
}
