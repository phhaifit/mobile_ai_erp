# Customer Portal API Contract

This document defines the expected API responses based on the Phase 2 implementation.

## Base Information
- **Base URL**: `https://api.your-erp.com` (configure in [endpoints.dart](lib/data/network/constants/endpoints.dart))
- **Customer API Base**: `{baseUrl}/api/v1/customer`
- **Auth Header**: `Authorization: Bearer {access_token}`
- **Tenant Header**: `X-Tenant-Id: {tenant_uuid}`

---

## 1. Authentication Endpoints

### POST `/api/v1/customer/auth/login`
**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600,
  "user": {
    "id": "uuid",
    "firstName": "John",
    "lastName": "Doe",
    "email": "user@example.com",
    "phone": "+1234567890",
    "avatarUrl": "https://...",
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

### POST `/api/v1/customer/auth/register`
**Request:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "+1234567890"
}
```

**Response (201):** Same as login response with new user data

### POST `/api/v1/customer/auth/forgot-password`
**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset link sent to email"
}
```

---

## 2. Profile Endpoints

### GET `/api/v1/customer/profile`
**Headers:** Requires auth token
**Response (200):**
```json
{
  "id": "uuid",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "avatarUrl": "https://example.com/avatar.jpg",
  "status": "active",
  "type": "individual",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

### PATCH `/api/v1/customer/profile`
**Headers:** Requires auth token
**Request:**
```json
{
  "firstName": "Jane",
  "phone": "+1234567891"
}
```

**Response (200):** Updated customer object (same shape as GET /profile)

### GET `/api/v1/customer/loyalty`
**Headers:** Requires auth token
**Response (200):**
```json
{
  "points": 1250,
  "tier": "silver",
  "nextTierPoints": 2000,
  "expiryDate": "2026-12-31T23:59:59Z"
}
```

---

## 3. Address Endpoints

### GET `/api/v1/customer/addresses`
**Headers:** Requires auth token
**Response (200):**
```json
{
  "data": [
    {
      "id": "uuid",
      "fullName": "John Doe",
      "phone": "+1234567890",
      "street": "123 Main St, Apt 4B",
      "city": "New York, NY 10001",
      "isDefault": true
    },
    {
      "id": "uuid",
      "fullName": "John Doe",
      "phone": "+1234567890",
      "street": "456 Oak Ave",
      "city": "Los Angeles, CA 90001",
      "isDefault": false
    }
  ]
}
```

### POST `/api/v1/customer/addresses`
**Headers:** Requires auth token
**Request:**
```json
{
  "fullName": "John Doe",
  "phone": "+1234567890",
  "street": "789 Pine Rd",
  "city": "Chicago, IL 60601"
}
```

**Response (201):** Created address object (same shape as GET addresses)

### PATCH `/api/v1/customer/addresses/{addressId}`
**Headers:** Requires auth token
**Request:**
```json
{
  "phone": "+9876543210",
  "city": "Boston, MA 02101"
}
```

**Response (200):** Updated address object

### DELETE `/api/v1/customer/addresses/{addressId}`
**Headers:** Requires auth token
**Response (204):** No content

### PATCH `/api/v1/customer/addresses/{addressId}/default`
**Headers:** Requires auth token
**Response (200):**
```json
{
  "success": true,
  "message": "Default address updated"
}
```

---

## 4. Order Endpoints

### GET `/api/v1/customer/orders`
**Headers:** Requires auth token
**Query Parameters:**
- `status` (optional): pending, shipped, delivered, canceled, returned
- `page` (optional, default=1): page number
- `pageSize` (optional, default=20): items per page

**Response (200):**
```json
{
  "data": [
    {
      "id": "order-uuid",
      "status": "delivered",
      "date": "2025-01-15T10:30:00Z",
      "totalAmount": 299.99,
      "shippingFee": 10.00,
      "shippingAddress": "123 Main St, New York, NY 10001",
      "paymentMethod": "credit_card",
      "items": [
        {
          "id": "item-uuid",
          "productId": "product-uuid",
          "productName": "Widget Pro",
          "quantity": 2,
          "price": 144.99,
          "imageUrl": "https://example.com/widget.jpg"
        }
      ]
    }
  ],
  "totalCount": 24,
  "page": 1,
  "pageSize": 20
}
```

### GET `/api/v1/customer/orders/{orderId}`
**Headers:** Requires auth token
**Response (200):** Single order object (same shape as items in list above)

### PATCH `/api/v1/customer/orders/{orderId}/cancel`
**Headers:** Requires auth token
**Response (200):**
```json
{
  "success": true,
  "order": {
    "id": "order-uuid",
    "status": "canceled",
    ...rest of order object
  }
}
```

### POST `/api/v1/customer/orders/{orderId}/return`
**Headers:** Requires auth token
**Request:**
```json
{
  "reason": "Defective product",
  "details": "The screen is cracked"
}
```

**Response (201):**
```json
{
  "id": "return-uuid",
  "orderId": "order-uuid",
  "reason": "Defective product",
  "details": "The screen is cracked",
  "status": "pending",
  "createdAt": "2025-01-20T15:45:00Z"
}
```

### POST `/api/v1/customer/orders/{orderId}/reorder`
**Headers:** Requires auth token
**Response (200):**
```json
{
  "success": true,
  "orderId": "new-order-uuid",
  "message": "Items added to cart. Proceed to checkout?"
}
```

---

## Error Responses

All endpoints follow standard error format:

### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ]
}
```

### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Invalid credentials or token expired"
}
```

### 403 Forbidden
```json
{
  "statusCode": 403,
  "message": "Access denied"
}
```

### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Resource not found"
}
```

### 409 Conflict
```json
{
  "statusCode": 409,
  "message": "Email already exists"
}
```

### 500 Internal Server Error
```json
{
  "statusCode": 500,
  "message": "Internal server error",
  "requestId": "req-uuid"
}
```

---

## Data Field Mappings

The Flutter app expects API responses in **camelCase** for customer endpoints:

| API Field | Dart Entity Property | Type |
|-----------|---------------------|------|
| `id` | `id` | String (UUID) |
| `firstName` | `firstName` | String |
| `lastName` | `lastName` | String |
| `fullName` | `fullName` | String (computed) |
| `email` | `email` | String |
| `phone` | `phone` | String |
| `avatarUrl` | `avatarUrl` | String (null ok) |
| `status` | `status` | Enum: active, inactive, blocked |
| `type` | `type` | Enum: individual, business |
| `createdAt` | `createdAt` | ISO8601 DateTime |
| `isDefault` | `isDefault` | Boolean |
| `street` | `street` | String |
| `city` | `city` | String |
| `orderStatus` | `status` | Enum: pending, shipped, delivered, canceled, returned |
| `date` | `date` | ISO8601 DateTime |
| `totalAmount` | `totalAmount` | Double (or string, see note) |
| `shippingFee` | `shippingFee` | Double |
| `productId` | `productId` | String (UUID) |
| `productName` | `productName` | String |
| `quantity` | `quantity` | Integer |
| `price` | `price` | Double |
| `imageUrl` | `imageUrl` | String |

**Note:** If API returns numeric values as strings, the `fromJson()` methods will parse them with `.toDouble()` or `.parseInt()`.

---

## Implementation Notes

### Auth Flow
1. User logs in → `login()` API called
2. Backend returns `accessToken`
3. Client stores token in `SharedPreferencesHelper`
4. `AuthInterceptor` automatically adds `Authorization: Bearer {token}` to all future requests
5. When token expires, backend returns 401
6. Client should refresh token or redirect to login

### Pagination
- Default: page=1, pageSize=20
- Maximum pageSize: 100 (per API catalog)
- Always check `totalCount` to determine if more pages exist

### Soft Delete
Orders use soft delete - canceled/returned orders still exist in API
- Query param `includeDeleted=true` if you want to show deleted records

### Required Headers
Every authenticated request must include:
```
Authorization: Bearer {accessToken}
X-Tenant-Id: {tenantId}
```

If `X-Tenant-Id` is missing, backend should return 400 or 403.

---

## Testing Notes

To test these endpoints, you can:

1. **Use Postman/Insomnia** with the above requests
2. **Mock with json-server** for local development
3. **Stub responses** in unit tests via `MockDioAdapter`
4. **Check logs** in the Flutter app - `LoggingInterceptor` logs all requests/responses

---

## Related Documentation
- [API Handoff Catalog](../api-handoff-catalog.md) - Full backend API specification
- [Phase 2 Integration](./PHASE_2_API_INTEGRATION.md) - Implementation details
- [Quick Start](./PHASE_2_QUICK_START.md) - Developer quick reference
