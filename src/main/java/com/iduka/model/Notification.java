package com.iduka.model;
import java.sql.Timestamp;
public class Notification {
    private int id, userId;
    private String type, message, link;
    private boolean read;
    private Timestamp createdAt;
    public Notification(){}
    public int getId(){return id;} public void setId(int v){this.id=v;}
    public int getUserId(){return userId;} public void setUserId(int v){this.userId=v;}
    public String getType(){return type;} public void setType(String v){this.type=v;}
    public String getMessage(){return message;} public void setMessage(String v){this.message=v;}
    public String getLink(){return link;} public void setLink(String v){this.link=v;}
    public boolean isRead(){return read;} public void setRead(boolean v){this.read=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){this.createdAt=v;}
}
