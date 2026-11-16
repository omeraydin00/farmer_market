// Firebase Emulator'a örnek çiftçi, müşteri ve ürün yükler.
// Sadece localhost'taki emülatöre yazar, gerçek projeye dokunmaz.
//
//   firebase emulators:start --project demo-farmer-market
//   node tool/seed_emulator.mjs
//
// Tüm hesapların şifresi: demo1234

const PROJECT = 'demo-farmer-market';
const AUTH = 'http://127.0.0.1:9099';
const FIRESTORE = 'http://127.0.0.1:8085';
const DOCS = `${FIRESTORE}/v1/projects/${PROJECT}/databases/(default)/documents`;
const PASSWORD = 'demo1234';

// Wikimedia Commons fotoğrafları (CC lisanslı)
const img = (path) => `https://upload.wikimedia.org/wikipedia/commons/thumb/${path}`;

const farmers = [
  {
    email: 'mehmet@ornek.com',
    name: 'Mehmet Yıldız',
    phone: '0500 000 00 01',
    location: 'Menemen, İzmir',
    products: [
      {
        name: 'Salkım Domates',
        price: 42.5,
        stockKg: 180,
        imageUrl: img('b/be/Grape_tomatoes_on_the_vine_at_Ljubljana_Central_Market.JPG/960px-Grape_tomatoes_on_the_vine_at_Ljubljana_Central_Market.JPG'),
        description: 'Sera değil, tarlada yetişti. Sabah toplanıp aynı gün yola çıkıyor.',
      },
      {
        name: 'Sivri Biber',
        price: 65,
        stockKg: 12,
        imageUrl: img('a/a2/28_Friggitello_green_sweet_chili_peppers_-_vegetable_price_in_Bologna%2C_Italy.jpg/960px-28_Friggitello_green_sweet_chili_peppers_-_vegetable_price_in_Bologna%2C_Italy.jpg'),
        description: 'Az acılı, ince kabuklu sivri biber. Kızartmalık ve közlemelik.',
      },
      {
        name: 'Salatalık',
        price: 38,
        stockKg: 95,
        imageUrl: img('6/62/Cucumber_in_Monday_Market_Kaduna_South.jpg/960px-Cucumber_in_Monday_Market_Kaduna_South.jpg'),
        description: 'Çıtır, ince kabuklu Çengelköy tipi salatalık.',
      },
      {
        name: 'Patlıcan',
        price: 48,
        stockKg: 60,
        imageUrl: img('1/1f/Eggplants_%28Aubergines%29_for_Sale_in_Market_-_Gjirokastra_-_Albania_%2840604346550%29.jpg/960px-Eggplants_%28Aubergines%29_for_Sale_in_Market_-_Gjirokastra_-_Albania_%2840604346550%29.jpg'),
        description: 'Kemer patlıcan, çekirdeği az. Közleme ve karnıyarık için.',
      },
    ],
  },
  {
    email: 'ayse@ornek.com',
    name: 'Ayşe Kaya',
    phone: '0500 000 00 02',
    location: 'Kumluca, Antalya',
    products: [
      {
        name: 'Çilek',
        price: 140,
        stockKg: 8,
        imageUrl: img('a/a2/Strawberries_in_basket_2018_G1.jpg/960px-Strawberries_in_basket_2018_G1.jpg'),
        description: 'İlaçsız yetiştirilen, kokulu yerli çilek. Sınırlı miktarda.',
      },
      {
        name: 'Kapya Biber',
        price: 72,
        stockKg: 40,
        imageUrl: img('8/87/Red_bell_peppers_for_sale_at_Safeway.jpg/960px-Red_bell_peppers_for_sale_at_Safeway.jpg'),
        description: 'Etli ve tatlı kapya biber, közlemeye çok uygun.',
      },
      {
        name: 'Kabak',
        price: 35,
        stockKg: 0,
        imageUrl: img('4/44/Zucchini_Erdverschmutzung-Josef_Schlaghecken.jpg/960px-Zucchini_Erdverschmutzung-Josef_Schlaghecken.jpg'),
        description: 'Taze sakız kabağı. Yeni hasat haftaya.',
      },
    ],
  },
  {
    email: 'hasan@ornek.com',
    name: 'Hasan Demir',
    phone: '0500 000 00 03',
    location: 'Bafra, Samsun',
    products: [
      {
        name: 'Kuru Soğan',
        price: 22,
        stockKg: 400,
        imageUrl: img('3/33/Onions_Veg_Stall_Ooty_Market_Nilgiris_Aug25_A7CR_07102.jpg/960px-Onions_Veg_Stall_Ooty_Market_Nilgiris_Aug25_A7CR_07102.jpg'),
        description: 'Bafra ovasından, kurutulmuş ve çuvallanmış. Toptan alımda indirim yapılır.',
      },
      {
        name: 'Patates',
        price: 28,
        stockKg: 350,
        imageUrl: img('b/b1/Kabale_Irish_Potato_Market_in_Western_Uganda_04.jpg/960px-Kabale_Irish_Potato_Market_in_Western_Uganda_04.jpg'),
        description: 'Kızartmalık ve haşlamalık, nişastası yüksek.',
      },
      {
        name: 'Amasya Elması',
        price: 55,
        stockKg: 150,
        imageUrl: img('3/34/Freshly_Picked_Apples_%28Unsplash%29.jpg/960px-Freshly_Picked_Apples_%28Unsplash%29.jpg'),
        description: 'Küçük boy, sulu ve mis kokulu Amasya elması.',
      },
      {
        name: 'Taze Fasulye',
        price: 85,
        stockKg: 25,
        imageUrl: img('9/9f/India_-_Koyambedu_Market_-_Green_Beans_01_%283986237781%29.jpg/960px-India_-_Koyambedu_Market_-_Green_Beans_01_%283986237781%29.jpg'),
        description: 'Ayşe kadın fasulye, kılçıksız.',
      },
    ],
  },
];

const customers = [
  { email: 'elif@ornek.com', name: 'Elif Şahin' },
  { email: 'can@ornek.com', name: 'Can Aydemir' },
];

// Firestore REST API değerleri tipli istiyor
function toValue(v) {
  if (v === null || v === undefined) return { nullValue: null };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (typeof v === 'number') return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  return { stringValue: String(v) };
}

function toFields(obj) {
  return Object.fromEntries(Object.entries(obj).map(([k, v]) => [k, toValue(v)]));
}

async function call(method, url, body) {
  const res = await fetch(url, {
    method,
    headers: { 'Content-Type': 'application/json', Authorization: 'Bearer owner' },
    body: body ? JSON.stringify(body) : undefined,
  });
  if (!res.ok) throw new Error(`${method} ${url} -> ${res.status} ${await res.text()}`);
  return res.status === 204 ? null : res.json();
}

async function createAccount(email) {
  const data = await call('POST', `${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo`, {
    email,
    password: PASSWORD,
    returnSecureToken: true,
  });
  return data.localId;
}

async function main() {
  // Önce emülatördeki eski veriyi temizle
  await call('DELETE', `${AUTH}/emulator/v1/projects/${PROJECT}/accounts`);
  await call('DELETE', `${FIRESTORE}/emulator/v1/projects/${PROJECT}/databases/(default)/documents`);

  let minutesAgo = 0;
  let productCount = 0;

  for (const farmer of farmers) {
    const uid = await createAccount(farmer.email);
    await call('PATCH', `${DOCS}/users/${uid}`, {
      fields: toFields({
        email: farmer.email,
        role: 'farmer',
        name: farmer.name,
        phone: farmer.phone,
        location: farmer.location,
        createdAt: new Date(),
      }),
    });

    for (const p of farmer.products) {
      minutesAgo += 37;
      await call('POST', `${DOCS}/products`, {
        fields: toFields({
          ...p,
          ownerId: uid,
          sellerName: farmer.name,
          sellerPhone: farmer.phone,
          sellerLocation: farmer.location,
          createdAt: new Date(Date.now() - minutesAgo * 60 * 1000),
        }),
      });
      productCount++;
    }
  }

  for (const customer of customers) {
    const uid = await createAccount(customer.email);
    await call('PATCH', `${DOCS}/users/${uid}`, {
      fields: toFields({ email: customer.email, role: 'customer', name: customer.name, createdAt: new Date() }),
    });
  }

  console.log(`${farmers.length} çiftçi, ${customers.length} müşteri, ${productCount} ürün eklendi.`);
  console.log(`Giriş: ${farmers[0].email} veya ${customers[0].email}, şifre: ${PASSWORD}`);
}

main().catch((e) => {
  console.error(e.message);
  console.error('Emülatör çalışıyor mu? firebase emulators:start --project demo-farmer-market');
  process.exit(1);
});
