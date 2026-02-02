module.exports = {
  testEnvironment: 'jsdom',
  testMatch: ['**/spec/javascript/**/*.test.js'],
  moduleNameMapper: {
    '^@hotwired/stimulus$': '<rootDir>/node_modules/@hotwired/stimulus',
  },
  setupFilesAfterEnv: ['<rootDir>/spec/javascript/setup.js'],
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  transformIgnorePatterns: [
    'node_modules/(?!(@hotwired)/)',
  ],
  collectCoverageFrom: [
    'lib/flexi_admin/javascript/controllers/**/*.js',
    '!lib/flexi_admin/javascript/controllers/index.js',
  ],
  coverageDirectory: 'coverage/javascript',
};
