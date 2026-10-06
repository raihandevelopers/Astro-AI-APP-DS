# MyFuture

AI Vedic astrology consultations — Flutter app + Node.js API + MongoDB.

## Free AI (Gemini)

Consultations use **Google Gemini free tier** — no payment required.

1. Open [Google AI Studio → API keys](https://aistudio.google.com/app/apikey)
2. Create a key (Google account only; no credit card)
3. Put it in `backend/.env`:

```env
GEMINI_API_KEY=your_key_here
```

4. Restart the API (`npm start` in `backend/`)

Without a key, the app still answers from the natal chart. With a key, you get real AI replies within Gemini’s free daily limits.

Optional free backup: [Groq](https://console.groq.com) → `GROQ_API_KEY=...`

## Run the API

```bash
cd backend
npm install
npm start
```

API: `http://localhost:4000`

OTP is printed in the API response (`OTP_ECHO=true`) so you can sign in without SMS.

## Run the app

```bash
flutter pub get
flutter run
```

- iOS simulator → `http://127.0.0.1:4000`
- Android emulator → `http://10.0.2.2:4000`
- Physical phone: `flutter run --dart-define=API_URL=http://YOUR_LAN_IP:4000/api`

## Admin panel (React)

```bash
cd admin
npm install
npm run dev
```

Open **http://localhost:5173** — admin key from `backend/.env` (`ADMIN_KEY`, default `myfuture-admin`).

The React app proxies API calls to `http://localhost:4000`. Keep the backend running.

New accounts get ₹50 welcome credit. Consultations are ₹10/minute. Wallet recharge packs are sandbox credits (no payment gateway in this build).
