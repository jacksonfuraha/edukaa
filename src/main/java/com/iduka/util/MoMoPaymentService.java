package com.iduka.util;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

/**
 * IDUKA Mobile Money Payment Service
 * Handles MTN MoMo and Airtel Money payment requests (USSD push to buyer's phone)
 *
 * In SANDBOX mode: simulates the payment request and returns a fake reference.
 * In PRODUCTION mode: calls real MTN/Airtel APIs.
 *
 * To go live, set env vars:
 *   PAYMENT_MODE=PRODUCTION
 *   MTN_SUBSCRIPTION_KEY=your_mtn_key
 *   MTN_API_USER=your_mtn_user
 *   MTN_API_KEY=your_mtn_api_key
 *   AIRTEL_CLIENT_ID=your_airtel_id
 *   AIRTEL_CLIENT_SECRET=your_airtel_secret
 */
public class MoMoPaymentService {

    private static final String MODE = getEnv("PAYMENT_MODE", "SANDBOX");

    public static class PaymentResult {
        public boolean  success;
        public String   reference;
        public String   message;
        public String   method;  // MTN or AIRTEL

        public PaymentResult(boolean s, String ref, String msg, String method) {
            this.success = s; this.reference = ref;
            this.message = msg; this.method = method;
        }
    }

    /**
     * Detect phone network from number prefix
     */
    public static String detectNetwork(String phone) {
        if (phone == null) return "UNKNOWN";
        String p = phone.replaceAll("[^0-9]", "");
        if (p.startsWith("250")) p = p.substring(3);
        if (p.startsWith("078") || p.startsWith("079") || p.startsWith("072") || p.startsWith("073")) return "MTN";
        if (p.startsWith("073") || p.startsWith("072")) return "MTN";
        if (p.startsWith("075") || p.startsWith("076") || p.startsWith("074")) return "AIRTEL";
        // Default prefix mapping for Rwanda
        String pre = p.length() >= 3 ? p.substring(0, 3) : "";
        return switch(pre) {
            case "078","079","072","073" -> "MTN";
            case "075","076","074"       -> "AIRTEL";
            default -> "MTN"; // default to MTN
        };
    }

    /**
     * Main method: send payment request to buyer's phone
     * @param buyerPhone  buyer's phone number (e.g. 0788123456 or 250788123456)
     * @param amount      amount in RWF
     * @param orderId     order ID for reference
     * @param productName product name for description
     */
    public static PaymentResult requestPayment(String buyerPhone, double amount, int orderId, String productName) {
        String network = detectNetwork(buyerPhone);
        String phone   = normalizePhone(buyerPhone);
        String ref     = "IDK-" + orderId + "-" + System.currentTimeMillis();

        if ("SANDBOX".equals(MODE)) {
            // Simulate payment in sandbox — logs what would happen in production
            System.out.println("[PAYMENT SANDBOX] Requesting " + amount + " RWF from " + phone + " via " + network);
            System.out.println("[PAYMENT SANDBOX] Order: " + orderId + " | Product: " + productName);
            System.out.println("[PAYMENT SANDBOX] Reference: " + ref);

            // Simulate success
            return new PaymentResult(true, ref,
                "Payment request sent to " + phone + " via " + network +
                " MoMo. Buyer will receive USSD prompt to enter PIN.", network);
        }

        // PRODUCTION mode
        if ("MTN".equals(network)) {
            return requestMTN(phone, amount, orderId, productName, ref);
        } else {
            return requestAirtel(phone, amount, orderId, productName, ref);
        }
    }

    /** MTN Mobile Money API (Rwanda) */
    private static PaymentResult requestMTN(String phone, double amount, int orderId, String desc, String ref) {
        try {
            String subKey  = getEnv("MTN_SUBSCRIPTION_KEY", "");
            String apiUser = getEnv("MTN_API_USER", "");
            String apiKey  = getEnv("MTN_API_KEY",  "");

            if (subKey.isEmpty()) {
                return new PaymentResult(false, ref, "MTN API not configured. Contact admin.", "MTN");
            }

            // Get access token
            String credentials = apiUser + ":" + apiKey;
            String encoded = java.util.Base64.getEncoder()
                .encodeToString(credentials.getBytes(StandardCharsets.UTF_8));

            URL tokenUrl = new URL("https://sandbox.momodeveloper.mtn.com/collection/token/");
            HttpURLConnection tokenConn = (HttpURLConnection) tokenUrl.openConnection();
            tokenConn.setRequestMethod("POST");
            tokenConn.setRequestProperty("Authorization", "Basic " + encoded);
            tokenConn.setRequestProperty("Ocp-Apim-Subscription-Key", subKey);
            tokenConn.setDoOutput(true);

            int tokenStatus = tokenConn.getResponseCode();
            if (tokenStatus != 200) {
                return new PaymentResult(false, ref, "MTN token failed: " + tokenStatus, "MTN");
            }

            String tokenResponse = readResponse(tokenConn);
            String accessToken   = extractJson(tokenResponse, "access_token");

            // Request to pay
            String payRef  = UUID.randomUUID().toString();
            String payload = "{" +
                "\"amount\": \"" + (int) amount + "\"," +
                "\"currency\": \"RWF\"," +
                "\"externalId\": \"" + ref + "\"," +
                "\"payer\": {\"partyIdType\": \"MSISDN\", \"partyId\": \"" + phone + "\"}," +
                "\"payerMessage\": \"Payment for " + desc + " on IDUKA\"," +
                "\"payeeNote\": \"Order #" + orderId + "\"" +
            "}";

            URL payUrl = new URL("https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay");
            HttpURLConnection payConn = (HttpURLConnection) payUrl.openConnection();
            payConn.setRequestMethod("POST");
            payConn.setRequestProperty("Authorization",              "Bearer " + accessToken);
            payConn.setRequestProperty("X-Reference-Id",             payRef);
            payConn.setRequestProperty("X-Target-Environment",       "sandbox");
            payConn.setRequestProperty("Ocp-Apim-Subscription-Key",  subKey);
            payConn.setRequestProperty("Content-Type",               "application/json");
            payConn.setDoOutput(true);

            try (OutputStream os = payConn.getOutputStream()) {
                os.write(payload.getBytes(StandardCharsets.UTF_8));
            }

            int status = payConn.getResponseCode();
            if (status == 202) {
                return new PaymentResult(true, payRef,
                    "MTN MoMo request sent! Buyer will receive USSD prompt on their phone.", "MTN");
            } else {
                return new PaymentResult(false, ref, "MTN payment failed: " + status, "MTN");
            }

        } catch (Exception e) {
            return new PaymentResult(false, ref, "MTN error: " + e.getMessage(), "MTN");
        }
    }

    /** Airtel Money API (Rwanda) */
    private static PaymentResult requestAirtel(String phone, double amount, int orderId, String desc, String ref) {
        try {
            String clientId     = getEnv("AIRTEL_CLIENT_ID",     "");
            String clientSecret = getEnv("AIRTEL_CLIENT_SECRET", "");

            if (clientId.isEmpty()) {
                return new PaymentResult(false, ref, "Airtel API not configured. Contact admin.", "AIRTEL");
            }

            // Get access token
            String tokenPayload = "{\"client_id\":\"" + clientId + "\",\"client_secret\":\"" + clientSecret +
                "\",\"grant_type\":\"client_credentials\"}";

            URL tokenUrl = new URL("https://openapi.airtel.africa/auth/oauth2/token");
            HttpURLConnection tokenConn = (HttpURLConnection) tokenUrl.openConnection();
            tokenConn.setRequestMethod("POST");
            tokenConn.setRequestProperty("Content-Type", "application/json");
            tokenConn.setDoOutput(true);
            try (OutputStream os = tokenConn.getOutputStream()) {
                os.write(tokenPayload.getBytes(StandardCharsets.UTF_8));
            }

            String tokenResponse = readResponse(tokenConn);
            String accessToken   = extractJson(tokenResponse, "access_token");

            // Request payment
            String payload = "{" +
                "\"reference\": \"" + ref + "\"," +
                "\"subscriber\": {\"country\": \"RW\", \"currency\": \"RWF\", \"msisdn\": \"" + phone + "\"}," +
                "\"transaction\": {\"amount\": " + (int) amount + ", \"country\": \"RW\", \"currency\": \"RWF\", \"id\": \"" + ref + "\"}" +
            "}";

            URL payUrl = new URL("https://openapi.airtel.africa/merchant/v1/payments/");
            HttpURLConnection payConn = (HttpURLConnection) payUrl.openConnection();
            payConn.setRequestMethod("POST");
            payConn.setRequestProperty("Authorization", "Bearer " + accessToken);
            payConn.setRequestProperty("Content-Type",  "application/json");
            payConn.setRequestProperty("X-Country",     "RW");
            payConn.setRequestProperty("X-Currency",    "RWF");
            payConn.setDoOutput(true);
            try (OutputStream os = payConn.getOutputStream()) {
                os.write(payload.getBytes(StandardCharsets.UTF_8));
            }

            int status = payConn.getResponseCode();
            if (status == 200 || status == 202) {
                return new PaymentResult(true, ref,
                    "Airtel Money request sent! Buyer will receive prompt on their phone.", "AIRTEL");
            } else {
                return new PaymentResult(false, ref, "Airtel payment failed: " + status, "AIRTEL");
            }

        } catch (Exception e) {
            return new PaymentResult(false, ref, "Airtel error: " + e.getMessage(), "AIRTEL");
        }
    }

    /** Normalize phone to international format 250XXXXXXXXX */
    public static String normalizePhone(String phone) {
        if (phone == null) return "";
        String p = phone.replaceAll("[^0-9]", "");
        if (p.startsWith("250")) return p;
        if (p.startsWith("0"))   return "250" + p.substring(1);
        return "250" + p;
    }

    private static String readResponse(HttpURLConnection conn) throws IOException {
        InputStream is = conn.getResponseCode() < 300 ? conn.getInputStream() : conn.getErrorStream();
        if (is == null) return "";
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            return sb.toString();
        }
    }

    private static String extractJson(String json, String key) {
        String search = "\"" + key + "\":\"";
        int start = json.indexOf(search);
        if (start < 0) return "";
        start += search.length();
        int end = json.indexOf("\"", start);
        return end > start ? json.substring(start, end) : "";
    }

    private static String getEnv(String key, String def) {
        String v = System.getenv(key);
        return (v != null && !v.trim().isEmpty()) ? v.trim() : def;
    }
}
