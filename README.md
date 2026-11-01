# Memeroll payment check

Premium unlocks only when PayPal confirms a payment. These files do that check. Nothing here has been deployed or run against PayPal yet.

## How it works

1. The site gives each browser a random member code and sends it to PayPal in the `custom` field.
2. PayPal tells `paypal-ipn` about each payment. The function asks PayPal to confirm the message is real, checks the receiver, currency and amount, then saves the member code as `active` (or `inactive` on a refund or when the subscription ends).
3. The site asks `premium-status` whether its code is `active`. If yes, Premium unlocks. If not, it stays locked.

## Set up

1. Run `schema.sql` in the Supabase SQL editor.
2. Install the Supabase CLI and link your project: `supabase link --project-ref YOUR_REF`
3. Set the secrets (use the email of the PayPal account that gets paid):
   `supabase secrets set PAYPAL_RECEIVER_EMAIL=you@example.com PRICE_CURRENCY=USD PRICE_MIN=1`
   Optional: `ALLOWED_ORIGIN=https://your-site.com` so only your site can call the status check.
4. Deploy both functions. PayPal sends no login token, so both use `--no-verify-jwt`:
   `supabase functions deploy paypal-ipn --no-verify-jwt`
   `supabase functions deploy premium-status --no-verify-jwt`
5. In `memeroll.html`, find `var PREMIUM = { ipn: "", status: "" };` and fill it in:
   `ipn: "https://YOUR_REF.supabase.co/functions/v1/paypal-ipn"`
   `status: "https://YOUR_REF.supabase.co/functions/v1/premium-status"`
6. In PayPal, turn on Instant Payment Notification (Profile, then Notifications) and use the same `paypal-ipn` address. This is a backup in case PayPal ignores the address sent with the button.

## Test before you take real money

Do one test payment (PayPal sandbox works: set `PAYPAL_SANDBOX=1`) and check that:
- the payment appears in `premium_members` as `active`, with the member code from the browser that paid;
- the Premium page unlocks after returning from PayPal;
- a different browser stays locked.

If `premium_members` stays empty, open the function logs. A line starting "ignored:" says why. The most likely cause is PayPal not passing the `custom` field through your hosted button.

## Things to know

- Anyone who has a member code can restore that Premium on another device. Treat the code like a password.
- A subscription that is cancelled keeps access until PayPal sends the end-of-term message, then switches off.
- The Premium tools run inside the web page, so a technically skilled visitor could still switch them on by editing the page in their own browser. This check stops normal use, not a determined hacker. Anything you must truly protect, such as paid downloads, has to be served by the backend.
