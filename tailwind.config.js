/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx}", "./components/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        ink: "#0F172A",
        muted: "#64748B",
        faint: "#94A3B8",
        border: "#E2E8F0",
        panel: "#F8FAFC",
        accent: "#6366F1",
        "accent-hover": "#4F52E5",
      },
    },
  },
  plugins: [],
};
