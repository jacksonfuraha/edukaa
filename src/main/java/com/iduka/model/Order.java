package com.iduka.model;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Order {
    private int id, buyerId, sellerId, productId, quantity;
    private BigDecimal unitPrice, totalPrice;
    private String status, paymentStatus, paymentMethod, paymentRef, paymentNetwork;
    private String buyerName, buyerEmail, buyerPhone;
    private String productName, sellerName;
    private String deliveryAddress;
    private boolean payslipSent;
    private String paymentRequestStatus; // PENDING_PAYMENT, PAYMENT_SENT, PAID, FAILED
    private Timestamp createdAt;

    public Order(){}
    public int getId(){return id;} public void setId(int v){this.id=v;}
    public int getBuyerId(){return buyerId;} public void setBuyerId(int v){this.buyerId=v;}
    public int getSellerId(){return sellerId;} public void setSellerId(int v){this.sellerId=v;}
    public int getProductId(){return productId;} public void setProductId(int v){this.productId=v;}
    public int getQuantity(){return quantity;} public void setQuantity(int v){this.quantity=v;}
    public BigDecimal getUnitPrice(){return unitPrice;} public void setUnitPrice(BigDecimal v){this.unitPrice=v;}
    public BigDecimal getTotalPrice(){return totalPrice;} public void setTotalPrice(BigDecimal v){this.totalPrice=v;}
    public String getStatus(){return status;} public void setStatus(String v){this.status=v;}
    public String getPaymentStatus(){return paymentStatus;} public void setPaymentStatus(String v){this.paymentStatus=v;}
    public String getPaymentMethod(){return paymentMethod;} public void setPaymentMethod(String v){this.paymentMethod=v;}
    public String getPaymentRef(){return paymentRef;} public void setPaymentRef(String v){this.paymentRef=v;}
    public String getPaymentNetwork(){return paymentNetwork;} public void setPaymentNetwork(String v){this.paymentNetwork=v;}
    public String getBuyerName(){return buyerName;} public void setBuyerName(String v){this.buyerName=v;}
    public String getBuyerEmail(){return buyerEmail;} public void setBuyerEmail(String v){this.buyerEmail=v;}
    public String getBuyerPhone(){return buyerPhone;} public void setBuyerPhone(String v){this.buyerPhone=v;}
    public String getProductName(){return productName;} public void setProductName(String v){this.productName=v;}
    public String getSellerName(){return sellerName;} public void setSellerName(String v){this.sellerName=v;}
    public String getDeliveryAddress(){return deliveryAddress;} public void setDeliveryAddress(String v){this.deliveryAddress=v;}
    public boolean isPayslipSent(){return payslipSent;} public void setPayslipSent(boolean v){this.payslipSent=v;}
    public String getPaymentRequestStatus(){return paymentRequestStatus;} public void setPaymentRequestStatus(String v){this.paymentRequestStatus=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){this.createdAt=v;}
}
