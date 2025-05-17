# RedshiftDemoDataWarehouse
Demo AWS Redshift
1.	Tạo Redshift serverless 
2.	Thiết lập mô hình dữ liệu và nhập dữ liệu
Tập dữ liệu The Open University Learning Analytics Dataset (OULAD)
Bộ dữ liệu chứa dữ liệu về các khóa học, sinh viên và tương tác của họ với Môi trường học tập ảo trực tuyến (VLE) cho bảy khóa học được chọn, được gọi là các mô-đun. Bộ dữ liệu giả định rằng có hai học kỳ mỗi năm và các khóa học bắt đầu vào tháng 2 và tháng 10 hàng năm. Học kỳ của khóa học được xác định bằng cột code_presentation trong bảng khóa học và các mô-đun mã được thêm chữ cái “B” và “J” tương ứng, với một năm gồm bốn chữ số làm tiền tố. Bộ dữ liệu bao gồm các bảng được kết nối bằng các mã định danh duy nhất . Tất cả các bảng đều được lưu trữ ở định dạng CSV. Mô hình dữ liệu bao gồm bảy bảng, với dữ liệu liên quan đến học sinh, mô-đun, và hoạt động.
![image](https://github.com/user-attachments/assets/05606f2c-3efe-41c8-8b0f-19ee345b4cd0)
Tạo star-schema
Tạo materialized view
Star schema
Đo lường kết quả học tập
 ![image](https://github.com/user-attachments/assets/4516666c-0e60-411e-98dc-4a86eed4905b)

4.	Thu thập tập tin liên tục từ Amazon S3
Cấu hình policy cho IAM role, redshift
Tạo S3 event integrations

Ngoài ra có thể lên lịch chạy câu lệnh truy vấn thay cho thu thập tập tin liên tục

4.	ETL bằng AWS GLUE
Tạo connection
Tạo kết nối giữa redshift, glue và s3 thông qua VPC, enpoint, IAM role
Trước hết thêm các policy cho IAM role, tạo endpoint, tùy chỉnh security group rồi mới tạo connection
Tạo AWS Glue job

 
 
 
 
 






















