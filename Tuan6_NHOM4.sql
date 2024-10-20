IF EXISTS (SELECT * FROM sys.databases WHERE name = 'QLCTGH_N4')
BEGIN
    USE master; -- Chuyển sang cơ sở dữ liệu master để có thể xóa được cơ sở dữ liệu khác
    ALTER DATABASE  QLCTGH_N4 SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Ngắt mọi kết nối
    DROP DATABASE QLCTGH_N4; -- Xóa cơ sở dữ liệu
END
--tạo database Quản lý công tác giao hàng-nhóm 4
create database QLCTGH_N4
go 
use QLCTGH_N4
--tạo tbl Quốc Gia
create table QuocGia
(
	QGiaNo varchar(10) primary key,
	tenQG nvarchar(20) not null
)
--tạo tbl tỉnh/thành phố
CREATE TABLE Tinh_ThanhPho
(
    id_TTP int PRIMARY KEY ,
    tenTinh nvarchar(30)  not null,
	QGiaNo varchar(10) foreign key references QuocGia(QGiaNo)
	on update
			cascade
		on delete
			cascade
)
--tạo tbl Quận/Huyện
CREATE TABLE QuanHuyen 
(
    id_QH char(5) PRIMARY KEY ,
    ten_QHuyen nvarchar(30)  not null,
    id_TTP int foreign key references Tinh_ThanhPho(id_TTP)
		on update
			cascade
		on delete
			cascade
)
--tạo tbl Phường/Xã
CREATE TABLE PhuongXa (
    id_PX char(5) PRIMARY KEY ,
    ten_PhuongXa nvarchar(100)  not null,
    id_QHuyen char(5) foreign key references QuanHuyen(id_QH)
		on update
			cascade
		on delete
			cascade
)
--tạo tbl KHACHHANG
create table KHACHHANG
(
	maKH char(10) primary key,
	tenCongTy nvarchar(50) not null,
	tenGiaoDich nvarchar(30) not null,
	Email varchar(50) unique not null,
	dienThoai varchar(11) unique not null,
	Fax char(10) unique not null,
	soNhaTenDuong nvarchar(50) not null,
	id_PX char(5) foreign key references PhuongXa(id_PX)
		on update
			cascade
		on delete
			cascade
)
--tạo tbl NHANVIEN
create table NHANVIEN
(
	maNV char(7) primary key,
	Ho nvarchar(6) not null,
	Ten nvarchar(6) not null,
	ngaySinh date not null,
	ngaylamViec date not null,
	diaChi nvarchar(100) not null,
	dienThoai varchar(11) unique not null,
	luongCoBan money,

)
--tạo tbl NHACUNGCAP
create table NHACUNGCAP
(
	maCT char(5) primary key,
	tenCongTy nvarchar(50) not null,
	tenGiaoDich nvarchar(50) not null,
	dienThoai varchar(11) unique not null,
	Fax char(10) unique not null,
	Email varchar(50) unique not null,
	soNhaTenDuong nvarchar(50) not null,
	id_PX char(5) foreign key references PhuongXa(id_PX)
		on update
			cascade
		on delete
			cascade
)
-- tạo tbl LOAIHANG
create table LOAIHANG
(
	maLH char(7) primary key,
	tenLH nvarchar(30) not null
)
--tạo tbl MATHANG
create table MATHANG
(
	maHang char(7) primary key,
	tenHang nvarchar(50) not null,
	maCT char(5) foreign key references NHACUNGCAP(maCT)
		on update
			cascade
		on delete
			cascade,
	maLH char(7) foreign key references LOAIHANg(maLH)
		on update
			cascade
		on delete
			cascade,
	soLuong decimal(8,0) not null,
	donViTinh money,
)
--tạo tbl ĐONATHANG
create table DONDATHANG
(
	soHD char(8) primary key,
	maKH char(10) foreign key references KHACHHANG(maKH)
		on update
			cascade
		on delete
			cascade,
	maNV char(7) foreign key references NHANVIEN(maNV)
		on update
			cascade
		on delete
			cascade,
	ngayDatHang date not null,
	ngayChuyenhang date not null,
	ngayGiaoHang date not null,
	soNhaTenDuong nvarchar(50) not null,
	id_PX char(5) foreign key references PhuongXa(id_PX)
		on update
			no action
		on delete 
			no action
)
--tạo tbl CHITIETDATHANG
create table CHITIETDATHANG
(
	soHD char(8) foreign key references DONDATHANG(soHD) ,
	maHang char(7) foreign key references MATHANG(maHang), 
	primary key(soHD, maHang),
	giaBan money not null,
	soLuong int not null,
	mucGiamGia decimal(3,2) not null
)

--ràng buộc cho SoLuong có default =1
alter table MATHANG
	add constraint DF_SOLG default 1 for soLuong
-- ràng buộc cho SoLuong có default =1 và mucGiamGia  có default =0
alter table CHITIETDATHANG
	add constraint DF_sLG default 1 for soluong,
		constraint DF_mGG default 0 for mucGiamGia

--setup ngayDatHang = now
alter table DONDATHANG
	add constraint CK_NgDH check(ngayDatHang = getdate()),
		constraint CK_NgCH check(ngayChuyenHang >= ngayDatHang),
		constraint CK_NgGH check(ngayGiaohang >= ngayChuyenHang)
alter table NHANVIEN
	add constraint CK_NgaySinh 
	CHECK (NgaySinh <= DATEADD(YEAR, -18, GETDATE()) AND 
			NgaySinh >= DATEADD(YEAR, -60, GETDATE()))
