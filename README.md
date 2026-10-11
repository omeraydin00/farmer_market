<p align="center">
  <img src="./assets/header.svg" alt="Farmer Market" width="100%" />
</p>

A mobile marketplace where farmers sell their produce directly to customers.

Flutter · Firebase (Authentication, Firestore, Storage) · Provider

<img alt="Farmer Market" src="https://github.com/user-attachments/assets/fc829c37-6937-404c-9761-31b481293a26" />

People sign up as a farmer or as a customer and see a different app for each. Farmers add their products with a price, stock in kilograms and a photo, and edit or remove them later. Customers search and sort the products by price, open a product to see its details and call the farmer straight from there. The app has light and dark themes, and everything is kept in sync through Firebase.

<p>
  <img width="49%" alt="Products" src="https://github.com/user-attachments/assets/96b7df3b-6a40-41eb-a199-0fba1e999bee" />
  <img width="49%" alt="Farmer panel" src="https://github.com/user-attachments/assets/86fa65ab-ed86-4cc7-a349-e87adf48afcf" />
</p>
<p>
  <img width="49%" alt="Add a product" src="https://github.com/user-attachments/assets/50f67160-36db-4c07-9a9f-4594c739f34d" />
  <img width="49%" alt="Profile" src="https://github.com/user-attachments/assets/fde09aa9-e471-41fc-be79-55006bc1a631" />
</p>

## Running it

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.22 or newer and an Android emulator or device.

```bash
git clone https://github.com/omeraydin00/farmer_market.git
cd farmer_market/farmer_market
flutter pub get
flutter run
```

The app connects to the Firebase project in `android/app/google-services.json`. To use your own, create a Firebase project and replace that file.
