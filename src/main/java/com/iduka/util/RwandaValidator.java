package com.iduka.util;

/**
 * Rwanda National ID and TIN validation.
 *
 * Rwanda National ID (Indangamuntu):
 * - 16 digits exactly
 * - Format: 1 19[YY] [XXXXXXXX] [C]
 *   Position 1: always 1
 *   Positions 2-5: birth year (e.g. 1990)
 *   Positions 6-8: sequence number
 *   Position 9-15: additional digits
 *   Position 16: check digit
 *
 * Rwanda TIN (Tax Identification Number):
 * - 9 digits exactly
 * - Starts with 1, 2, 3, 4, 5, 6, or 7
 */
public class RwandaValidator {

    /**
     * Validate Rwanda National ID format.
     * Returns null if valid, error message if invalid.
     */
    public static String validateNationalId(String idNumber) {
        if (idNumber == null || idNumber.trim().isEmpty()) {
            return "National ID number is required.";
        }
        String id = idNumber.trim().replaceAll("\\s+", "");

        // Must be exactly 16 digits
        if (!id.matches("\\d{16}")) {
            return "National ID must be exactly 16 digits (numbers only). Example: 1199080012345678";
        }

        // First digit must be 1 (Rwanda ID format)
        if (!id.startsWith("1")) {
            return "Invalid National ID — Rwanda IDs start with 1.";
        }

        // Extract birth year (digits 2-5)
        int birthYear;
        try {
            birthYear = Integer.parseInt(id.substring(1, 5));
        } catch (NumberFormatException e) {
            return "Invalid National ID format.";
        }

        // Birth year should be reasonable (1900-2010 for adults)
        if (birthYear < 1900 || birthYear > 2010) {
            return "Invalid National ID — birth year " + birthYear + " is not valid.";
        }

        // Person must be at least 18 years old to register as seller
        int currentYear = java.time.Year.now().getValue();
        if (currentYear - birthYear < 18) {
            return "You must be at least 18 years old to register as a seller.";
        }

        return null; // Valid
    }

    /**
     * Validate Rwanda TIN format.
     * Returns null if valid, error message if invalid.
     */
    public static String validateTIN(String tinNumber) {
        if (tinNumber == null || tinNumber.trim().isEmpty()) {
            return "TIN number is required.";
        }
        String tin = tinNumber.trim().replaceAll("\\s+", "");

        // Must be exactly 9 digits
        if (!tin.matches("\\d{9}")) {
            return "TIN number must be exactly 9 digits. Example: 101234567";
        }

        // Rwanda TINs start with 1-7
        char first = tin.charAt(0);
        if (first < '1' || first > '7') {
            return "Invalid TIN — Rwanda TIN numbers start with digits 1 to 7.";
        }

        return null; // Valid
    }

    /**
     * Validate that ID number and full name are consistent.
     * Basic check: name shouldn't be clearly fake.
     */
    public static String validateSellerName(String fullName) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "Full name is required.";
        }
        String name = fullName.trim();
        if (name.length() < 5) {
            return "Please enter your full legal name (at least 5 characters).";
        }
        // Must have at least 2 words (first + last name)
        if (!name.contains(" ")) {
            return "Please enter your full name (first and last name).";
        }
        // No numbers in name
        if (name.matches(".*\\d.*")) {
            return "Full name cannot contain numbers.";
        }
        return null; // Valid
    }

    /**
     * Check if an ID number has the right format to exist in Rwanda's system.
     * This is a format-level check — not a real database lookup.
     */
    public static boolean isPlausibleId(String idNumber) {
        if (idNumber == null) return false;
        String id = idNumber.trim().replaceAll("\\s+", "");
        return id.matches("1\\d{15}");
    }
}
