package com.iduka.model;
import java.sql.Timestamp;
public class VideoComment {
    private int id, videoId, userId;
    private String comment, userName, avatarUrl;
    private Timestamp createdAt;
    public VideoComment(){}
    public int getId(){return id;} public void setId(int v){this.id=v;}
    public int getVideoId(){return videoId;} public void setVideoId(int v){this.videoId=v;}
    public int getUserId(){return userId;} public void setUserId(int v){this.userId=v;}
    public String getComment(){return comment;} public void setComment(String v){this.comment=v;}
    public String getUserName(){return userName;} public void setUserName(String v){this.userName=v;}
    public String getAvatarUrl(){return avatarUrl;} public void setAvatarUrl(String v){this.avatarUrl=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){this.createdAt=v;}
}
