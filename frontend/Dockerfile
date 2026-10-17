FROM node:22-bookworm-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --include=dev
COPY . .

ENV REACT_APP_USER_SERVICE_URL=/user-api
ENV REACT_APP_PRODUCT_SERVICE_URL=/product-api
ENV REACT_APP_CART_SERVICE_URL=/cart-api
ENV REACT_APP_ORDER_SERVICE_URL=/order-api
RUN npm run build

FROM nginx:stable-alpine AS production
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]