package com.iduka.model;
import java.sql.Timestamp;

public class InboxItem {
    private int    otherId, productId, unreadCount;
    private String otherName, productName, lastMessage;
    private Timestamp lastTime;

    public int       getOtherId()     { return otherId; }
    public void      setOtherId(int v){ this.otherId = v; }
    public int       getProductId()     { return productId; }
    public void      setProductId(int v){ this.productId = v; }
    public int       getUnreadCount()     { return unreadCount; }
    public void      setUnreadCount(int v){ this.unreadCount = v; }
    public String    getOtherName()      { return otherName; }
    public void      setOtherName(String v){ this.otherName = v; }
    public String    getProductName()      { return productName; }
    public void      setProductName(String v){ this.productName = v; }
    public String    getLastMessage()      { return lastMessage; }
    public void      setLastMessage(String v){ this.lastMessage = v; }
    public Timestamp getLastTime()         { return lastTime; }
    public void      setLastTime(Timestamp v){ this.lastTime = v; }
}
