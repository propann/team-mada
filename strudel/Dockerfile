FROM node:18

# Install pnpm
RUN npm install -g pnpm

# Create workdir inside the container
WORKDIR /app

# Clone the REAL Strudel project (from Codeberg)
RUN git clone https://codeberg.org/uzu/strudel.git .

# Install dependencies using pnpm
RUN pnpm install

# Expose Strudel dev server port
EXPOSE 4321

# Run Strudel web REPL
CMD ["pnpm", "dev", "--host", "0.0.0.0", "--port", "4321"]


