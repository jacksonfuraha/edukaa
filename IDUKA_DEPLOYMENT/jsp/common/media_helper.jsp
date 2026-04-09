<%!
/**
 * Builds the correct display URL for a stored image/video path.
 * DB stores: "products/uuid.jpg" or "videos/uuid.mp4"
 * Served at:  /CONTEXTPATH/uploads/products/uuid.jpg  (via context.xml alias)
 */
public static String mediaUrl(String ctx, String stored) {
    if (stored == null || stored.trim().isEmpty()) return ctx + "/images/no-image.svg";
    stored = stored.trim();
    if (stored.startsWith("uploads/")) return ctx + "/" + stored;     // legacy
    if (stored.startsWith("images/"))  return ctx + "/" + stored;     // static
    if (stored.startsWith("default"))  return ctx + "/images/no-image.svg";
    return ctx + "/uploads/" + stored; // new format: "products/uuid.jpg"
}
%>
