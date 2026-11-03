/** @type {import('tailwindcss').Config} */
// resources/tailwind.config.v3.js
// Template token untuk proyek Laravel 11 / Tailwind CSS v3
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
    './storage/framework/views/*.php',
    './resources/views/**/*.blade.php',
    './resources/js/**/*.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Nunito Sans Variable"', ...defaultTheme.fontFamily.sans],
        display: ['"Fraunces Variable"', ...defaultTheme.fontFamily.serif],
      },
      colors: {
        brand: {
          50: '#fbf5f1',
          100: '#f5e8df',
          200: '#eacfbe',
          300: '#dbae94',
          400: '#c68866',
          500: '#9a5d38',
          600: '#7a4a2e', // Primary CTA
          700: '#633b25',
          800: '#4d2e1d',
          900: '#3a2316',
          950: '#24150d',
        },
        accent: {
          50: '#fef2f5',
          100: '#fde3ea',
          200: '#fbc8d6',
          300: '#f59fb6',
          400: '#ee7595',
          500: '#e4577a',
          600: '#cf3a62',
          700: '#ad2b4f',
          800: '#8f2645',
          900: '#78233d',
          950: '#430e1f',
        },
        ink: {
          50: '#faf7f5',
          100: '#f2ede9',
          200: '#e4dcd5',
          300: '#cec2b8',
          400: '#a89889',
          500: '#857465',
          600: '#6a5b4e',
          700: '#54483e',
          800: '#3d342d',
          900: '#2b241f',
          950: '#1a1512',
        },
        surface: {
          DEFAULT: '#fff8f0',
          raised: '#ffffff',
          sunken: '#f7ede2',
        },
        wa: {
          DEFAULT: '#25d366',
          hover: '#1ebe5b',
          ink: '#052e1f',
        },
      },
      borderRadius: {
        card: '1.5rem',
        btn: '9999px',
        field: '0.875rem',
      },
      boxShadow: {
        card: '0 1px 2px rgb(43 36 31 / 0.05), 0 1px 1px rgb(43 36 31 / 0.03)',
        raised: '0 8px 24px -6px rgb(43 36 31 / 0.14), 0 2px 6px rgb(43 36 31 / 0.06)',
        overlay: '0 24px 48px -12px rgb(43 36 31 / 0.28)',
      },
    },
  },
  plugins: [],
}
