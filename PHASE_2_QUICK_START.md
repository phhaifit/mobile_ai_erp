# Quick Start - Phase 2 API Integration

## What Was Done
Converted the mock-based customer portal to use **real API calls** for:
- Authentication (login/register/forgot password)
- Profile management
- Address book
- Order history and details
- Return/exchange requests
- Loyalty points

## Key Architecture

### 1. New API Clients (Network Layer)
- **`CustomerApi`** - Auth + profile endpoints
- **`AddressApi`** - Address CRUD endpoints  
- **`OrderApi`** - Order operations endpoints

These use `DioClient` with automatic Bearer token injection via `AuthInterceptor`.

### 2. Data Sources (Adapter Pattern)
```
API Clients → Data Sources → Repositories → Use Cases → Stores
```

Example flow:
```dart
CustomerApi.login() 
  → CustomerApiDataSource.login() 
  → CustomerRepositoryImpl.login() 
  → CustomerLoginUseCase.call()
  → Store action
  → UI update
```

### 3. Where to Make Changes

#### To change API endpoints:
→ [endpoints.dart](lib/data/network/constants/endpoints.dart)

#### To add new API operations:
→ Create method in `CustomerApi`, `AddressApi`, or `OrderApi`
→ Add corresponding method to `*ApiDataSource`
→ Add to repository interface
→ Create use case if needed
→ Connect store action

#### To update store logic:
→ [address_store.dart](lib/presentation/account/store/address_store.dart)
→ [order_store.dart](lib/presentation/account/store/order_store.dart)
→ [profile_store.dart](lib/presentation/account/store/profile_store.dart)

#### To update UI to use API:
→ Call store actions: `addressStore.fetchAddresses()`, `orderStore.fetchOrders()`, etc.
→ Observe store properties: `addressStore.isLoading`, `addressStore.addresses`

## Common Tasks

### Task: Handle Login
1. Call `CustomerLoginUseCase` from login screen
2. Store access token in `SharedPreferencesHelper`
3. Token auto-added to future requests by `AuthInterceptor`
4. Redirect to account home

### Task: Load Orders with Status Filter
```dart
// In order screen, e.g., when tab is "Shipped"
await orderStore.fetchOrders(status: 'shipped');
```

### Task: Refresh Data
```dart
// Address book
await addressStore.fetchAddresses();

// Orders
await orderStore.fetchOrders();

// Profile
await profileStore.fetchProfile();
```

### Task: Handle API Errors
Currently basic error handling exists. To improve:
1. Catch exceptions in store actions
2. Set `isLoading = false` in error handler
3. Trigger user-facing error UI (snackbar, dialog)
4. Consider offline mode for critical data

## Troubleshooting

**"Customer API is returning snake_case, not camelCase"**
→ Check field mapping in `fromJson()` methods
→ Per API catalog, some endpoints use different naming conventions

**"Auth token not being sent"**
→ Verify token is stored in `SharedPreferencesHelper`
→ Check `AuthInterceptor` is registered in NetworkModule
→ Verify `X-Tenant-Id` header if required by backend

**"Getting 401 errors"**
→ Token may have expired
→ Implement token refresh in error interceptor
→ Or clear token and redirect to login

**"Data not loading"**
→ Check API base URL in endpoints.dart points to correct server
→ Verify network connectivity
→ Check DioClient timeout settings if requests are slow

## Testing Checklist Before Deployment

- [ ] API base URL configured correctly
- [ ] Login flow works end-to-end
- [ ] Profile loads and displays correctly
- [ ] Address CRUD operations work
- [ ] Order history loads with filtering
- [ ] Order detail view displays full information
- [ ] Return request submission works
- [ ] Logout clears token and redirects to login
- [ ] Error messages display on API failures
- [ ] Works with/without internet (offline handling if required)

## Next Phase Considerations

1. **Offline Mode** - Cache API responses locally with Sembast
2. **Real-time Updates** - WebSocket for order status changes
3. **Image Upload** - Handle address/profile photo uploads
4. **Pagination** - Implement lazy loading for long order lists
5. **Search/Filter** - Add advanced filtering to order history
6. **Analytics** - Track user interactions for metrics
