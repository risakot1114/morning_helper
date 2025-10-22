/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // パステルカラーパレット
        'morning-pink': '#FFB6C1',
        'morning-blue': '#87CEEB',
        'morning-yellow': '#FFF8DC',
        'morning-green': '#98FB98',
        'morning-purple': '#DDA0DD',
        'morning-orange': '#FFE4B5',
        'morning-mint': '#F0FFF0',
        'morning-lavender': '#E6E6FA',
      },
      fontFamily: {
        'cute': ['Comic Sans MS', 'cursive'],
      },
      borderRadius: {
        'xl': '1rem',
        '2xl': '1.5rem',
        '3xl': '2rem',
      },
      boxShadow: {
        'soft': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        'card': '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
      },
    },
  },
  plugins: [],
}
