package com.iduka.model;
import java.sql.Timestamp;
public class User {
    private int id;
    private String fullName, email, phone, password, role;
    private String country, province, district, sector, cell, village;
    private String avatarUrl;
    private boolean active;
    private Timestamp createdAt;
    // Seller verification fields
    private String idNumber, tinNumber, idCardUrl;
    private boolean verified;

    public User() {}
    public int getId(){return id;} public void setId(int id){this.id=id;}
    public String getFullName(){return fullName;} public void setFullName(String v){this.fullName=v;}
    public String getEmail(){return email;} public void setEmail(String v){this.email=v;}
    public String getPhone(){return phone;} public void setPhone(String v){this.phone=v;}
    public String getPassword(){return password;} public void setPassword(String v){this.password=v;}
    public String getRole(){return role;} public void setRole(String v){this.role=v;}
    public String getCountry(){return country;} public void setCountry(String v){this.country=v;}
    public String getProvince(){return province;} public void setProvince(String v){this.province=v;}
    public String getDistrict(){return district;} public void setDistrict(String v){this.district=v;}
    public String getSector(){return sector;} public void setSector(String v){this.sector=v;}
    public String getCell(){return cell;} public void setCell(String v){this.cell=v;}
    public String getVillage(){return village;} public void setVillage(String v){this.village=v;}
    public String getAvatarUrl(){return avatarUrl;} public void setAvatarUrl(String v){this.avatarUrl=v;}
    public boolean isActive(){return active;} public void setActive(boolean v){this.active=v;}
    public Timestamp getCreatedAt(){return createdAt;} public void setCreatedAt(Timestamp v){this.createdAt=v;}
    public String getIdNumber(){return idNumber;} public void setIdNumber(String v){this.idNumber=v;}
    public String getTinNumber(){return tinNumber;} public void setTinNumber(String v){this.tinNumber=v;}
    public String getIdCardUrl(){return idCardUrl;} public void setIdCardUrl(String v){this.idCardUrl=v;}
    public boolean isVerified(){return verified;} public void setVerified(boolean v){this.verified=v;}
}
