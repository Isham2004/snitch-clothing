# Firebase Backend Integration — Snitch Clothing

This document describes the Firebase backend wired into the existing Snitch
Clothing Flutter UI. No UI/visual elements were changed — only backend logic,
services, and provider wiring.

---

## 1. Firebase project & app

- **Project ID:** `snitch-clothing`
- **Android package:** `com.isham.snitchclothing` (matches `google-services.json`)
- **Storage bucket:** `snitch-clothing.firebasestorage.app`

The Android Gradle setup, `MainActivity.kt` path, and `firebase_options.dart`
are aligned with the provided `google-services.json`.

---

## 2. Mandatory manual steps in Firebase Console

Open the [Firebase Console](https://console.firebase.google.com/) for project
`snitch-clothing` and complete the following:

### 2.1 Enable Authentication
1. Go to **Build → Authentication → Get started**.
2. Open the **Sign-in method** tab.
3. Enable **Email/Password**. Save.

> Without this step, registration/login will fail with
> `operation-not-allowed`.

### 2.2 Create Cloud Firestore database
1. Go to **Build → Firestore Database → Create database**.
2. Pick your region (e.g. `nam5` or your nearest one).
3. Start in **Production mode**.
4. Replace the default rules with the contents of `firestore.rules`
   (committed at the repo root). Click **Publish**.

### 2.3 Enable Cloud Storage
1. Go to **Build → Storage → Get started**.
2. Start in **Production mode**, accept the default bucket.
3. Replace the default rules with the contents of `storage.rules` (at repo
   root). Click **Publish**.

### 2.4 (Optional but recommended) Firestore composite indexes
The app uses simple `where` + `orderBy` queries which Firestore handles
automatically. No manual indexes are required at this time.

### 2.5 Add SHA-1/SHA-256 (only required if you later enable Google sign-in)
Email/password auth does **not** need SHA keys.

### 2.6 iOS-only (optional)
If you build for iOS, run `flutterfire configure` or add a
`GoogleService-Info.plist` for an iOS app inside the same Firebase project.

---

## 3. Firestore collection structure

```
products/                                  # publicly readable
  {productId}                              # e.g. "1", "2"…
    name              string
    brand             string
    price             number
    originalPrice     number | null
    imageUrl          string
    additionalImages  array<string>
    category          string
    description       string
    sizes             array<string>
    colors            array<string>
    rating            number
    reviewCount       number
    isNew             bool
    isFeatured        bool
    stock             number
    tag               string | null
    searchKeywords    array<string>        # auto-generated for client search

users/
  {uid}                                    # = Firebase Auth UID
    name              string
    email             string
    phone             string
    address           string
    avatarUrl         string
    createdAt         timestamp
    updatedAt         timestamp

    orders/
      {autoId}
        orderId         string             # human-readable e.g. "ORD-1234567"
        date            timestamp
        items           array<map>         # { productId, productName, productImage, price, quantity, selectedSize, selectedColor }
        subtotal        number
        shipping        number
        total           number
        itemCount       number
        status          string             # Confirmed | Processing | Shipped | Delivered | Cancelled
        address         string
        paymentMethod   string
        createdAt       timestamp

    favorites/
      {productId}                          # full product map (denormalized)

    addresses/
      {autoId}
        label           string
        fullName        string
        phone           string
        street          string
        city            string
        zip             string
        isDefault       bool

carts/
  {uid}
    updatedAt           timestamp
    items/
      {itemKey}                            # = "<productId>__<size>__<color>"
        productId, productName, productImage, productBrand, productCategory,
        price, originalPrice, quantity, selectedSize, selectedColor
```

---

## 4. Firebase Storage structure

```
avatars/{uid}/avatar_{timestamp}.{ext}     # user-uploaded profile photo
products/{productId}/image_{timestamp}.{ext}   # admin-only product image
```

---

## 5. Files created or modified

### Created
- `lib/firebase_options.dart`
- `lib/services/auth_service.dart`
- `lib/services/product_service.dart`
- `lib/services/cart_service.dart`
- `lib/services/order_service.dart`
- `lib/services/profile_service.dart`
- `lib/services/storage_service.dart`
- `lib/services/product_seed_service.dart`
- `lib/services/firebase_error_handler.dart`
- `lib/providers/products_provider.dart`
- `firestore.rules`
- `storage.rules`
- `FIREBASE_SETUP.md` (this file)
- `android/app/src/main/kotlin/com/isham/snitchclothing/MainActivity.kt`

### Modified
- `pubspec.yaml` *(already had firebase_core, firebase_auth, cloud_firestore, firebase_storage, image_picker)*
- `lib/main.dart` — Firebase initialization, seeding, session wiring
- `lib/models/product.dart` — `fromMap` / `toMap`
- `lib/models/cart_item.dart` — `fromMap` / `toMap` / stable `key`
- `lib/models/order_model.dart` — `fromMap` / `toMap`
- `lib/models/user_profile.dart` — `fromMap` / `toMap` / `copyWith`, plus `DeliveryAddress`
- `lib/providers/cart_provider.dart` — Firestore-backed, async, guest-merge
- `lib/providers/favorites_provider.dart` — Firestore-backed
- `lib/providers/user_provider.dart` — Auth, profile, orders, addresses, photo
- `lib/screens/splash_screen.dart` — Routes based on auth state (session persistence)
- `lib/screens/auth/login_screen.dart` — Firebase login + working forgot-password
- `lib/screens/auth/register_screen.dart` — Firebase registration
- `lib/screens/home/home_screen.dart` — Products from Firestore
- `lib/screens/products/product_list_screen.dart` — Products from Firestore
- `lib/screens/cart/cart_screen.dart` — Uses item key for variants
- `lib/screens/checkout/checkout_screen.dart` — Persists orders to Firestore
- `lib/screens/profile/profile_screen.dart` — Photo upload, change password, addresses
- `lib/screens/main_scaffold.dart` — Awaited async logout
- `android/app/build.gradle.kts` — google-services plugin, package id, min SDK 23, multidex
- `android/settings.gradle.kts` — google-services plugin classpath

### Removed
- `android/app/src/main/kotlin/com/snitch/snitch_clothing/MainActivity.kt`
  (replaced under the correct `com.isham.snitchclothing` package)

---

## 6. Product data

Firestore is the **only** source of products, categories, and banners — the
app no longer ships with any local seed data or mock fallback. The earlier
seeding scaffolding (`product_seed_service.dart`, `mock_data.dart`) has been
removed now that Firestore is populated.

If you ever need to reset or repopulate Firestore, add documents directly
via the Firebase Console, or use the Firebase Admin SDK from a one-off
script. The app expects these collections to exist:

- `products/{id}` — see field list in §3
- `categories/{slug}` — `{ name: string, order: number }`
- `banners/{id}` — `{ title, subtitle, image, tag, order }`

---

## 7. Implemented features (all wired to UI)

| Feature | Implementation |
| --- | --- |
| Sign up | `AuthService.signUp`, `RegisterScreen._register` |
| Sign in | `AuthService.signIn`, `LoginScreen._login` |
| Logout | `UserProvider.logout`, profile + drawer buttons |
| Password reset | `AuthService.sendPasswordReset`, `LoginScreen` "Forgot Password?" |
| Session persistence | `AuthService.authStateChanges` listened in `UserProvider`, splash routes accordingly |
| Products listing | `ProductService.getAll` via `ProductsProvider`, home & shop screens |
| Featured & new arrivals | `ProductsProvider.featured/newArrivals` |
| Category filtering | `ProductsProvider.byCategory`, product list chips |
| Product detail | Existing screen consumes the passed `Product` |
| Search | `ProductsProvider.search`, `_ProductSearchDelegate` |
| Add/remove/update cart | `CartProvider` (Firestore subcollection per user) |
| Cart persistence | Synced via `CartService.watchItems` |
| Checkout & order placement | `OrderService.placeOrder`, `UserProvider.placeOrder` |
| Order history | `OrderService.watchOrders` stream → `UserProvider.orders` |
| Order details | Existing expandable `_OrderCard` |
| Profile view & edit | `ProfileScreen`, `UserProvider.updateProfile` |
| Avatar upload | `image_picker` + `StorageService.uploadAvatar` |
| Delivery addresses | `_AddressesScreen`, `ProfileService.addresses` subcollection |
| Change password | `AuthService.changePassword` (re-auth + update) |
| Loading & error UI | Try/catch + snack bars + spinners on all flows |

---

## 8. Verification

```bash
flutter pub get
flutter analyze   # 0 errors / 0 warnings (only pre-existing withOpacity infos)
flutter run       # or `flutter build apk --debug`
```

The Android Gradle build on this Windows machine fails with
`Failed to create parent directory ...\.gradle\caches\...` — a Windows
file-system / permissions issue (not a code issue). Run as admin, free disk
space, or clean the Gradle cache:

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"
flutter clean; flutter pub get; flutter run
```

---

## 9. Recommended local testing checklist

1. Launch app on emulator/device.
2. Splash → Login screen (no signed-in user).
3. Tap **Sign Up**, create an account (real email).
4. App navigates to Home; products list loads from Firestore (auto-seeded
   on the first authenticated launch — see §6).
5. Open a product, choose size & color, **Add to Cart** → cart badge updates.
6. Open **Cart** → adjust qty, swipe to remove → numbers refresh.
7. **Proceed to Checkout** → fill address → place order → success dialog.
8. Open **My Orders** → new order appears with **Confirmed** status.
9. Open **Profile** → tap camera on avatar → pick photo → uploads to Storage.
10. Profile → **Change Password** → enter current + new → password updates.
11. Profile → **Saved Addresses** → add a default address.
12. Logout from drawer or profile → back to Login.
13. Login again → cart, favorites, profile, addresses, orders all persist.
14. From Login → **Forgot Password?** → request reset → email arrives.
