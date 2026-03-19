package com.iduka.model;
import java.sql.Timestamp;

public class ChatMessage {
    private int id, senderId, receiverId, productId;
    private String message, senderName;
    private boolean isRead;
    private boolean isDelivered;
    private boolean isSeen;
    private Timestamp sentAt;

    public ChatMessage(){}
    public int getId(){return id;} public void setId(int v){this.id=v;}
    public int getSenderId(){return senderId;} public void setSenderId(int v){this.senderId=v;}
    public int getReceiverId(){return receiverId;} public void setReceiverId(int v){this.receiverId=v;}
    public int getProductId(){return productId;} public void setProductId(int v){this.productId=v;}
    public String getMessage(){return message;} public void setMessage(String v){this.message=v;}
    public String getSenderName(){return senderName;} public void setSenderName(String v){this.senderName=v;}
    public boolean isRead(){return isRead;} public void setRead(boolean v){this.isRead=v;}
    public boolean isDelivered(){return isDelivered;} public void setDelivered(boolean v){this.isDelivered=v;}
    public boolean isSeen(){return isSeen;} public void setSeen(boolean v){this.isSeen=v;}
    public Timestamp getSentAt(){return sentAt;} public void setSentAt(Timestamp v){this.sentAt=v;}
}
