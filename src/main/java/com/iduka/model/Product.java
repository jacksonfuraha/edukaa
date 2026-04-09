package com.iduka.model;
import java.math.BigDecimal;
import java.sql.Timestamp;
public class Product {
    private int id, sellerId, categoryId, stock;
    private String name, description, imageUrl, sellerName;
    private BigDecimal price;
    private boolean active;
    private Timestamp createdAt;
    public Product(){}
    public int getId(){return id;} public void setId(int v){this.id=v;}
    public int getSellerId(){return sellerId;} public void setSellerId(int v){this.sellerId=v;}
    public int getCategoryId(){return categoryId;} public void setCategoryId(int v){this.categoryId=v;}
    public int getStock(){return stock;} public void setStock(int v){this.stock=v;}
    public String getName(){return name;} public void setName(String v){this.name=v;}
    public String getDescription(){return description;} public void setDescription(String v){this.description=v;}
    public String getImageUrl(){return imageUrl;} public void setImageUrl(String v){this.imageUrl=v;}
    public String getSellerName(){return sellerName;} public void setSellerName(String v){this.sellerName=v;}
    public BigDecimal getPrice(){return price;} public void setPrice(BigDecimal v){this.price=v;}
    public boolean isActive(){return active;} public void setActive(boolean v){this.active=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){this.createdAt=v;}
}
