<%-- Usage: include this, then call imgUrl(ctx, product.imageUrl) in scriptlet --%>
<%!
// Returns the correct URL for a stored imageUrl value
public static String imgUrl(String ctx, String stored) {
    if (stored == null || stored.isEmpty()
            || stored.startsWith("images/")
            || stored.startsWith("default-")) {
        return ctx + "/images/default-product.svg";
    }
    // stored = "products/uuid.jpg" or "videos/uuid.mp4"
    return ctx + "/uploads/" + stored;
}
public static String videoUrl(String ctx, String stored) {
    if (stored == null || stored.isEmpty()) return "";
    if (stored.startsWith("uploads/")) return ctx + "/" + stored; // legacy
    return ctx + "/uploads/" + stored;
}
%>
