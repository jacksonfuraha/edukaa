package com.iduka.model;
import java.sql.Timestamp;
public class ProductVideo {
    private int id, sellerId, productId, likes, commentCount;
    private String title, videoUrl, thumbnailUrl, sellerName;
    private Timestamp createdAt;
    public ProductVideo(){}
    public int getId(){return id;} public void setId(int v){this.id=v;}
    public int getSellerId(){return sellerId;} public void setSellerId(int v){this.sellerId=v;}
    public int getProductId(){return productId;} public void setProductId(int v){this.productId=v;}
    public int getLikes(){return likes;} public void setLikes(int v){this.likes=v;}
    public int getCommentCount(){return commentCount;} public void setCommentCount(int v){this.commentCount=v;}
    public String getTitle(){return title;} public void setTitle(String v){this.title=v;}
    public String getVideoUrl(){return videoUrl;} public void setVideoUrl(String v){this.videoUrl=v;}
    public String getThumbnailUrl(){return thumbnailUrl;} public void setThumbnailUrl(String v){this.thumbnailUrl=v;}
    public String getSellerName(){return sellerName;} public void setSellerName(String v){this.sellerName=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){this.createdAt=v;}
}
