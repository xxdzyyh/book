# http mutilpart  

[TOC]

### 客户端数据封装



使用 mutilpart 可以上传多个文件，文件的类型可以不同，在 Content-Type 里设置类型就可以。

```
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-0-0"
Content-Type: application/octet-stream

frame data
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-1-131"
Content-Type: application/octet-stream

frame data
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-2-1001"
Content-Type: application/octet-stream

frame data
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-3-2001"
Content-Type: application/octet-stream

frame data
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-4-3001"
Content-Type: application/octet-stream

frame data
--Boundary-2a02c3802a356d9d--
```



之前，[图片 图片] -> multipart -> server -> multipart  -> [图片 图片]

现在加入 gzip 压缩，将之前 multipart 使用 gzip 压缩，然后用 multipart/form 上传到服务器 。

分隔符使用 "Boundary-" + sessionId

[图片 图片] -> multipart  -> gzip - > multipart -> server -> multipart -> unzip -> multipart  -> [图片 图片]



1. 开始录制，创建一个文件 sessionid-0.tmp
2. 添加新的帧，如果偏移时间转成分钟数大于当前分钟数，创建一个新的文件 sessionid-n.tmp
3. 

每分钟上传一次，所以上报文件格式为

文件名为 sessionid + 序号(iOS使用minute作为序号，从0开始).



```
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-0"
Content-Type: application/octet-stream
gzip-data

--Boundary-2a02c3802a356d9d--
```

```
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-0-0"
Content-Type: application/octet-stream

frame data
--Boundary-2a02c3802a356d9d
Content-Disposition: form-data; name="replay"; filename="2a02c3802a356d9d-1-131"
Content-Type: application/octet-stream

frame data
--Boundary-2a02c3802a356d9d--
```









### 使用 MultipartStream 解析 multipart/form data



```
import java.io.ByteArrayInputStream;

import org.apache.commons.fileupload.MultipartStream;

public class MultipartTest {

    // Lines should end with CRLF
    public static final String MULTIPART_BODY =
            "Content-Type: multipart/form-data; boundary=--AaB03x\r\n"
            + "\r\n"
            + "----AaB03x\r\n"
            + "Content-Disposition: form-data; name=\"submit-name\"\r\n"
            + "\r\n"
            + "Larry\r\n"
            + "----AaB03x\r\n"
            + "Content-Disposition: form-data; name=\"files\"; filename=\"file1.txt\"\r\n"
            + "Content-Type: text/plain\r\n"
            + "\r\n"
            + "HELLO WORLD!\r\n"
            + "----AaB03x--\r\n";

    public static void main(String[] args) throws Exception {

        byte[] boundary = "--AaB03x".getBytes();

        ByteArrayInputStream content = new ByteArrayInputStream(MULTIPART_BODY.getBytes());

        @SuppressWarnings("deprecation")
        MultipartStream multipartStream =
                new MultipartStream(content, boundary);

        boolean nextPart = multipartStream.skipPreamble();
        while (nextPart) {
            String header = multipartStream.readHeaders();
            System.out.println("");
            System.out.println("Headers:");
            System.out.println(header);
            System.out.println("Body:");
            multipartStream.readBodyData(System.out);
            System.out.println("");
            nextPart = multipartStream.readBoundary();
        }
    }
}
```

