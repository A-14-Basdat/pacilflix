-- CONTRIBUTORS -- 
CREATE TABLE CONTRIBUTORS(
    id UUID PRIMARY KEY, 
    nama VARCHAR(50) NOT NULL,
    jenis_kelamin INT NOT NULL CHECK (jenis_kelamin IN (0, 1)),
    kewarganegaraan VARCHAR(50) NOT NULL
);

-- PENULIS_SKENARIO --
CREATE TABLE PENULIS_SKENARIO(
    id UUID PRIMARY KEY,
    FOREIGN KEY (id) REFERENCES CONTRIBUTORS(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- PEMAIN --
CREATE TABLE PEMAIN(
    id UUID PRIMARY KEY,
    FOREIGN KEY (id) REFERENCES CONTRIBUTORS(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- SUTRADARA --
CREATE TABLE SUTRADARA(
    id UUID PRIMARY KEY,
    FOREIGN KEY (id) REFERENCES CONTRIBUTORS(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TAYANGAN 
CREATE TABLE TAYANGAN(
    id UUID PRIMARY KEY,
    judul VARCHAR(100) NOT NULL,
    sinopsis VARCHAR(255) NOT NULL,
    asal_negara VARCHAR(50) NOT NULL,
    sinopsis_trailer VARCHAR(255) NOT NULL,
    url_video_trailer VARCHAR(255) NOT NULL,
    release_date_trailer DATE NOT NULL,
    id_sutradara UUID,
    FOREIGN KEY (id_sutradara) REFERENCES SUTRADARA(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- PENGGUNA --
CREATE TABLE PENGGUNA(
    username VARCHAR(50) PRIMARY KEY,
    password VARCHAR(50) NOT NULL,
    id_tayangan UUID,
    negara_asal VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- PAKET --
CREATE TABLE PAKET(
    nama VARCHAR(50) PRIMARY KEY,
    harga INT NOT NULL CHECK (harga >= 0),
    resolusi_layar VARCHAR(50) NOT NULL
);

-- DUKUNGAN_PERANGKAT -- 
CREATE TABLE DUKUNGAN_PERANGKAT(
    nama_paket VARCHAR(50),
    dukungan_perangkat VARCHAR(50),
    PRIMARY KEY (nama_paket, dukungan_perangkat),
    FOREIGN KEY (nama_paket) REFERENCES PAKET(nama) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TRANSACTION --
CREATE TABLE TRANSACTION(
    username VARCHAR(50),
    start_date_time DATE,
    end_date_time DATE,
    nama_paket VARCHAR(50),
    metode_pembayaran VARCHAR(50) NOT NULL,
    timestamp_pembayaran TIMESTAMP NOT NULL,
    PRIMARY KEY (username, start_date_time), 
    FOREIGN KEY (username) REFERENCES PENGGUNA(username) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (nama_paket) REFERENCES PAKET(nama) ON UPDATE CASCADE ON DELETE CASCADE
);

-- MEMAINKAN_TAYANGAN --
CREATE TABLE MEMAINKAN_TAYANGAN(
    id_tayangan UUID,
    id_pemain UUID,
    PRIMARY KEY (id_tayangan, id_pemain),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN(id)  ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_pemain) REFERENCES PEMAIN(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- MENULIS_SKENARIO_TAYANGAN 
CREATE TABLE MENULIS_SKENARIO_TAYANGAN(
    id_tayangan UUID,
    id_penulis_skenario UUID,
    PRIMARY KEY (id_tayangan, id_penulis_skenario),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_penulis_skenario) REFERENCES PENULIS_SKENARIO(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- GENRE_TAYANGAN --
CREATE TABLE GENRE_TAYANGAN(
    id_tayangan UUID,
    genre VARCHAR(50),
    PRIMARY KEY (id_tayangan, genre),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- PERUSAHAAN_PRODUKSI --
CREATE TABLE PERUSAHAAN_PRODUKSI(
    nama VARCHAR(100) PRIMARY KEY
);

-- PERSETUJUAN --
CREATE TABLE PERSETUJUAN(
    nama VARCHAR(100),
    id_tayangan UUID,
    tanggal_persetujuan DATE,
    durasi INT NOT NULL CHECK (durasi >= 0),
    biaya INT NOT NULL CHECK (biaya >= 0),
    tanggal_mulai_penayangan DATE NOT NULL,
    PRIMARY KEY (nama, id_tayangan, tanggal_persetujuan),
    FOREIGN KEY (nama) REFERENCES PERUSAHAAN_PRODUKSI(nama) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- SERIES --
CREATE TABLE SERIES(
    id_tayangan UUID PRIMARY KEY,
    FOREIGN KEY(id_tayangan) REFERENCES TAYANGAN(id)
);

-- FILM --
CREATE TABLE FILM(
    id_tayangan UUID PRIMARY KEY,
    url_video_film VARCHAR(255) NOT NULL,
    release_date_film DATE NOT NULL,
    durasi_film INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- EPISODE --
CREATE TABLE EPISODE(
    id_series UUID,
    sub_judul VARCHAR(100),
    sinopsis VARCHAR (255) NOT NULL,
    durasi INT NOT NULL DEFAULT 0,
    url_video VARCHAR(255) NOT NULL,
    release_date DATE NOT NULL,
    PRIMARY KEY (id_series, sub_judul),
    FOREIGN KEY (id_series) REFERENCES SERIES (id_tayangan) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ULASAN --
CREATE TABLE ULASAN(
    id_tayangan UUID,
    username VARCHAR(50),
    timestamp TIMESTAMP,
    rating INT NOT NULL DEFAULT 0,
    deskripsi VARCHAR(255),
    PRIMARY KEY (username, timestamp),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES PENGGUNA(username) ON UPDATE CASCADE ON DELETE CASCADE
);

-- DAFTAR_FAVORIT --
CREATE TABLE DAFTAR_FAVORIT(
    timestamp TIMESTAMP,
    username VARCHAR(50),
    judul VARCHAR(50) NOT NULL,
    PRIMARY KEY (timestamp, username),
    FOREIGN KEY (username) REFERENCES PENGGUNA(username) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TAYANGAN_MEMILIKI_DAFTAR_FAVORIT --
CREATE TABLE TAYANGAN_MEMILIKI_DAFTAR_FAVORIT(
    id_tayangan UUID,
    timestamp TIMESTAMP, 
    username VARCHAR(50),
    PRIMARY KEY (id_tayangan, timestamp, username),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (username, timestamp) REFERENCES DAFTAR_FAVORIT(username, timestamp) ON UPDATE CASCADE ON DELETE CASCADE
);

-- RIWAYAT_NONTON --
CREATE TABLE RIWAYAT_NONTON(
    id_tayangan UUID,
    username VARCHAR(50),
    start_date_time TIMESTAMP,
    end_date_time TIMESTAMP NOT NULL,
    PRIMARY KEY (username, start_date_time),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES PENGGUNA(username) ON UPDATE CASCADE ON DELETE CASCADE
);

-- TAYANGAN_TERUNDUH --
CREATE TABLE TAYANGAN_TERUNDUH(
    id_tayangan UUID,
    username VARCHAR(50), 
    timestamp TIMESTAMP,
    PRIMARY KEY(id_tayangan, username, timestamp),
    FOREIGN KEY(id_tayangan) REFERENCES TAYANGAN(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES PENGGUNA(username) ON UPDATE CASCADE ON DELETE CASCADE
);


-- INSERT DATA --

INSERT INTO CONTRIBUTORS VALUES ('6e737d14-7189-4952-9673-f39f53931e2c','Janith Fleetwood',1.0,'Kazakhstan'),
	('6d0e5d1c-53dd-48e4-ace8-5a123fdae30f','Willi Coorington',1.0,'Indonesia'),
	('52854e69-d59c-4db8-a55a-2f1a69ecec01','Alwin Vidloc',0.0,'Philippines'),
	('9db6acea-56be-45a0-9df0-6e7a9d09a3c6','Blanche Gurley',1.0,'Indonesia'),
	('1fb310e3-8b9d-4efe-aced-2b599c7185b9','Ty Treby',0.0,'China'),
	('07955104-4e23-4d0a-9e02-6bb7fdbce046','Desmund Ovell',0.0,'Ukraine'),
	('59988ac6-7dfa-40e6-aee6-4a89d02e94f2','Eldin Trigg',0.0,'China'),
	('1f60851a-62d4-4913-a07e-a6450ca0dfd4','Bat Hawick',0.0,'Sierra Leone'),
	('3dd54242-7e3a-41ea-a555-0ba5360e0d2e','Clayborn Carletti',0.0,'Portugal'),
	('ebae3d7a-171d-4864-9da2-dbc637b895f4','Barny Sarjeant',0.0,'Malaysia'),
	('f4070bb9-49ca-44dc-a2c7-d9bb6427c29a','Jerrold Wythe',0.0,'Indonesia'),
	('c80e7251-27bf-4632-8206-1bf70f03ac5d','Marcelo Reford',0.0,'China'),
	('e68f6dd5-2b78-43f5-9633-8ff6a7a87595','Laurie Emmet',1.0,'Poland'),
	('f33c0bb6-9689-4b05-b9b5-47c034768b4d','Brendin Fatharly',0.0,'France'),
	('f47e951a-abe8-4413-954e-18f32957a88e','Tracey Paulusch',1.0,'Netherlands'),
	('5854667f-dbf6-4863-9ec9-10bc6a3248ad','Malvin Sillars',0.0,'Poland'),
	('9963b673-2cb4-4768-80e6-816420bdf06f','Marissa Spendley',1.0,'Slovenia'),
	('2bf07ea8-f20d-43b5-91bc-2147e17fce8c','Tyler Cleal',0.0,'Indonesia'),
	('de0c3690-c706-40b2-a335-d8130c3aa03d','Shirley Dudgeon',1.0,'China'),
	('2fc4362a-9252-4809-8406-562e7c3dcf50','Torey Margrett',0.0,'Indonesia'),
	('3a5a3641-2115-42dd-8e96-c24d2289b0bd','Urson Billingsly',0.0,'Indonesia'),
	('cb5d214c-4733-4aa5-96e5-65aae576e107','Justen Osband',0.0,'Indonesia'),
	('705e14c8-96fc-4302-a637-46b242c6071d','Abrahan Drews',0.0,'Sweden'),
	('fd1e1220-e450-469a-b5ab-9dacf7b4196a','Joya Baser',1.0,'Thailand'),
	('ff4623ab-ab1a-4113-a563-d0f726e3f628','Zebadiah Lowey',0.0,'Brazil'),
	('84ca57d2-308d-4143-b5bb-42c0c186b158','Crawford Silverton',0.0,'China'),
	('e59939ff-9324-4e7d-bc4f-3f39aef5159b','Daven Barrim',0.0,'Nicaragua'),
	('913af2e5-a04d-4e2b-81c8-c7b83f6cd1db','Shurlocke Gounard',0.0,'Russia'),
	('2f57132c-cb3d-4d1c-a999-59ac18cbe770','Iorgo Ryhorovich',0.0,'China'),
	('27d238d7-39b4-4385-8515-914056f0d3b3','Giselbert Egerton',0.0,'Poland'),
	('b65817b4-2b56-4e3c-b3b1-6094ed5cfd8c','Nessie Tolworthie',1.0,'Russia'),
	('966cb526-b850-41e9-879a-eb525855304f','Arnoldo Enoksson',0.0,'Thailand'),
	('cf410683-bd1a-4b6b-9c37-aa6df5c7cd3a','Dalt Leppard',0.0,'China'),
	('0d97370e-b604-478e-87bd-cadf747e36f7','Olimpia Geany',1.0,'Mongolia'),
	('e572cbab-f064-431a-b777-e1f66ca93db9','Mark Bagger',0.0,'Indonesia'),
	('a239dfed-e7a7-451b-aabc-68e8e97f7d53','Renaud Broomhead',0.0,'Philippines'),
	('d503fc33-e369-498e-b304-73acdf682d39','Ethyl Whitland',1.0,'China'),
	('4c802e3c-05ed-43c4-934a-e79d28da2ad1','Pamela Nellies',1.0,'Mongolia'),
	('8b26a793-181b-47f0-8527-5ad421f6f08b','Shamus Okker',0.0,'France'),
	('5622077f-f3bd-45b5-87ff-4ab8cba74866','Bill Buney',0.0,'Indonesia'),
	('e191701b-ea7f-46e3-b1cb-a574d59cd316','Peter Hardaker',0.0,'Philippines'),
	('fe88c2bb-a53f-4cf8-888a-2adfa4f9a8ec','Dallas Duhig',0.0,'China'),
	('16eb8ca6-d8b0-4d02-b9c2-6403824d1bc6','Phebe Pentecust',1.0,'China'),
	('432c0e4d-e426-4359-af31-05ab6e00be9c','Antonina Clerc',1.0,'China'),
	('8d3feba0-234a-4116-82da-269aefc8f59d','Burnard Caunt',0.0,'China'),
	('1b33c919-760c-4611-848a-b4f521c27a00','Tore Delap',0.0,'Colombia'),
	('12f40471-e20e-45b8-836e-0ccfbd61cf74','Alwyn Dillaway',0.0,'China'),
	('fb1504d7-a3ca-4631-a790-d9e9dc4ad33d','Son Gibson',0.0,'Greece'),
	('abe8d13e-4f7d-4cee-a42d-10b6f5f86dd8','Brantley Felkin',0.0,'Poland'),
	('5bc3ad0a-73f3-47d2-bbb5-96804277ba26','Lorna Kegley',1.0,'China'),
	('b2fd8497-c91e-49b4-9368-add6eb4fd25b','Maureen Brickstock',1.0,'Portugal'),
	('0b7148c1-0aed-4cdc-ae04-063935fb1700','Mohammed Noell',0.0,'Burundi'),
	('be747bb7-1651-4d24-9115-73bf55f6c6f0','Tomasina Zanetello',1.0,'Russia'),
	('67558cfd-d7a8-4b45-9f4b-a6025b2e7c9e','Brigit McManus',1.0,'Poland'),
	('3bfe2712-3f91-436f-9368-e73639f09bf0','Boniface Bum',0.0,'Peru'),
	('48e67063-99f3-442c-9824-4ace71571f1f','Hephzibah Shadfourth',1.0,'Portugal'),
	('c2dba860-801f-40d7-a24d-9cc405985b24','Amitie Isakowicz',1.0,'Brazil'),
	('fb9266e5-65d1-4f37-93ef-157b1d7d76e9','Chiquita Greenley',1.0,'Brazil'),
	('c30b7675-cccc-40e4-8501-73b75f9a6646','Enrichetta Woolager',1.0,'Vietnam'),
	('f638a046-8260-4587-8154-875b39480c10','Wandie Jaulme',1.0,'France'),
	('4b063c20-b8fe-4e61-b58b-2ab2b2a4925e','Tiff Braine',1.0,'China'),
	('3b83cded-7c6e-45c3-bfb6-cf5540edf1a0','Jervis Derrington',0.0,'Sweden'),
	('533716f2-6978-4ca5-9b6a-1e5db02d732f','Valdemar Truran',0.0,'Indonesia'),
	('7bf9f811-ca22-47a5-8121-67422ebd3485','Edgard McCullouch',0.0,'Ukraine'),
	('c7d7ee5c-0754-4667-bb8e-9cc63a57d79e','Levi Kervin',0.0,'Colombia');


INSERT INTO PENULIS_SKENARIO VALUES ('6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('52854e69-d59c-4db8-a55a-2f1a69ecec01'),
	('9db6acea-56be-45a0-9df0-6e7a9d09a3c6'),
	('1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('07955104-4e23-4d0a-9e02-6bb7fdbce046'),
	('59988ac6-7dfa-40e6-aee6-4a89d02e94f2'),
	('1f60851a-62d4-4913-a07e-a6450ca0dfd4'),
	('3dd54242-7e3a-41ea-a555-0ba5360e0d2e'),
	('ebae3d7a-171d-4864-9da2-dbc637b895f4'),
	('f4070bb9-49ca-44dc-a2c7-d9bb6427c29a'),
	('c80e7251-27bf-4632-8206-1bf70f03ac5d'),
	('e68f6dd5-2b78-43f5-9633-8ff6a7a87595'),
	('f33c0bb6-9689-4b05-b9b5-47c034768b4d'),
	('f47e951a-abe8-4413-954e-18f32957a88e'),
	('5854667f-dbf6-4863-9ec9-10bc6a3248ad'),
	('9963b673-2cb4-4768-80e6-816420bdf06f'),
	('2bf07ea8-f20d-43b5-91bc-2147e17fce8c'),
	('de0c3690-c706-40b2-a335-d8130c3aa03d'),
	('2fc4362a-9252-4809-8406-562e7c3dcf50'),
	('3a5a3641-2115-42dd-8e96-c24d2289b0bd'),
	('cb5d214c-4733-4aa5-96e5-65aae576e107'),
	('705e14c8-96fc-4302-a637-46b242c6071d'),
	('fd1e1220-e450-469a-b5ab-9dacf7b4196a'),
	('ff4623ab-ab1a-4113-a563-d0f726e3f628'),
	('84ca57d2-308d-4143-b5bb-42c0c186b158'),
	('e59939ff-9324-4e7d-bc4f-3f39aef5159b'),
	('913af2e5-a04d-4e2b-81c8-c7b83f6cd1db'),
	('2f57132c-cb3d-4d1c-a999-59ac18cbe770'),
	('27d238d7-39b4-4385-8515-914056f0d3b3'),
	('b65817b4-2b56-4e3c-b3b1-6094ed5cfd8c');


INSERT INTO PEMAIN VALUES ('6e737d14-7189-4952-9673-f39f53931e2c'),
	('966cb526-b850-41e9-879a-eb525855304f'),
	('cf410683-bd1a-4b6b-9c37-aa6df5c7cd3a'),
	('0d97370e-b604-478e-87bd-cadf747e36f7'),
	('e572cbab-f064-431a-b777-e1f66ca93db9'),
	('a239dfed-e7a7-451b-aabc-68e8e97f7d53'),
	('d503fc33-e369-498e-b304-73acdf682d39'),
	('4c802e3c-05ed-43c4-934a-e79d28da2ad1'),
	('8b26a793-181b-47f0-8527-5ad421f6f08b'),
	('5622077f-f3bd-45b5-87ff-4ab8cba74866'),
	('e191701b-ea7f-46e3-b1cb-a574d59cd316'),
	('fe88c2bb-a53f-4cf8-888a-2adfa4f9a8ec'),
	('16eb8ca6-d8b0-4d02-b9c2-6403824d1bc6'),
	('432c0e4d-e426-4359-af31-05ab6e00be9c'),
	('8d3feba0-234a-4116-82da-269aefc8f59d'),
	('1b33c919-760c-4611-848a-b4f521c27a00'),
	('12f40471-e20e-45b8-836e-0ccfbd61cf74'),
	('fb1504d7-a3ca-4631-a790-d9e9dc4ad33d'),
	('abe8d13e-4f7d-4cee-a42d-10b6f5f86dd8'),
	('5bc3ad0a-73f3-47d2-bbb5-96804277ba26'),
	('b2fd8497-c91e-49b4-9368-add6eb4fd25b'),
	('0b7148c1-0aed-4cdc-ae04-063935fb1700'),
	('be747bb7-1651-4d24-9115-73bf55f6c6f0'),
	('67558cfd-d7a8-4b45-9f4b-a6025b2e7c9e'),
	('3bfe2712-3f91-436f-9368-e73639f09bf0'),
	('48e67063-99f3-442c-9824-4ace71571f1f'),
	('c2dba860-801f-40d7-a24d-9cc405985b24'),
	('fb9266e5-65d1-4f37-93ef-157b1d7d76e9'),
	('c30b7675-cccc-40e4-8501-73b75f9a6646'),
	('f638a046-8260-4587-8154-875b39480c10'),
	('6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('52854e69-d59c-4db8-a55a-2f1a69ecec01'),
	('9db6acea-56be-45a0-9df0-6e7a9d09a3c6'),
	('1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('07955104-4e23-4d0a-9e02-6bb7fdbce046'),
	('e59939ff-9324-4e7d-bc4f-3f39aef5159b'),
	('913af2e5-a04d-4e2b-81c8-c7b83f6cd1db'),
	('2f57132c-cb3d-4d1c-a999-59ac18cbe770'),
	('27d238d7-39b4-4385-8515-914056f0d3b3'),
	('b65817b4-2b56-4e3c-b3b1-6094ed5cfd8c');


INSERT INTO SUTRADARA VALUES ('4b063c20-b8fe-4e61-b58b-2ab2b2a4925e'),
	('3b83cded-7c6e-45c3-bfb6-cf5540edf1a0'),
	('533716f2-6978-4ca5-9b6a-1e5db02d732f'),
	('7bf9f811-ca22-47a5-8121-67422ebd3485'),
	('c7d7ee5c-0754-4667-bb8e-9cc63a57d79e'),
	('6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('52854e69-d59c-4db8-a55a-2f1a69ecec01'),
	('9db6acea-56be-45a0-9df0-6e7a9d09a3c6'),
	('1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('07955104-4e23-4d0a-9e02-6bb7fdbce046');


INSERT INTO TAYANGAN VALUES ('d2718217-0546-4b92-9c3f-4e71b31d85d8','Friends','Friends adalah acara TV Komedi tahun 90-an, yang berbasis di Manhattan, tentang 6 teman yang menjalani hampir semua pengalaman hidup bersama.','Amerika Serikat','I''ll be there for you and you''ll be there for me too','https://www.youtube.com/watch?v=IEEbUzffzrk','2021-07-08 00:00:00','1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','Seinfeld','Kesialan yang terus berlanjut dari komedian stand-up Kota New York yang neurotik, Jerry Seinfeld, dan teman-temannya.','Amerika Serikat','Bass riff playing','https://www.youtube.com/watch?v=hQXKyIG_NS4','2023-06-11 00:00:00','1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','The Office','The Office adalah serial televisi sitkom mockumentary Amerika yang menggambarkan kehidupan kerja sehari-hari karyawan\\/','Amerika Serikat','An NBC comedy not for everyone. Just anyone that works.','https://www.youtube.com/watch?v=tNcDHWpselE','2023-03-30 00:00:00','1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','Brooklyn Nine-Nine','Serial komedi mengikuti eksploitasi Detektif Jake Peralta dan rekan-rekannya yang beragam dan menyenangkan saat mereka mengawasi Kantor Polisi.','Amerika Serikat','The law. Without the order.','https://www.youtube.com/watch?v=sEOuJ4z5aTc','2023-08-31 00:00:00','6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','Suits','Bertempat di sebuah firma hukum korporat fiktif di Kota New York, film ini mengikuti Mike Ross yang menggunakan ingatan fotografisnya untuk mencari pekerjaan.','Amerika Serikat','Two lawyers. One degree.','https://www.youtube.com/watch?v=cUnkjEIW2-o','2023-11-08 00:00:00','1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','Jurassic Park','Ahli paleontologi Alan Grant dan Ellie Sattler dan ahli matematika.','Amerika Serikat','65 million years in the making.	','https://www.youtube.com/watch?v=lc0UehYemQA','2023-02-08 00:00:00','52854e69-d59c-4db8-a55a-2f1a69ecec01'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','Superbad','Dua sahabat tak terpisahkan menjalani minggu-minggu terakhir sekolah menengah atas dan diundang ke pesta rumah besar-besaran. ','Amerika Serikat','Two inseparable best friends navigate the last weeks of high school.','https://www.youtube.com/watch?v=4eaZ_48ZYog','2022-01-27 00:00:00','6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','Her','Karena patah hati setelah pernikahannya berakhir, Theodore menjadi terpesona dengan sistem operasi baru.','Amerika Serikat','A lonely writer develops an unlikely relationship with his newly-purchased OS.','https://www.youtube.com/watch?v=dJTU48_yghs','2023-03-10 00:00:00','1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551','Lost in Translation','Bintang film tua yang kesepian bernama Bob Harris dan pengantin baru yang berkonflik, Charlotte (Scarlett Johansson), bertemu di Tokyo.','Amerika Serikat','Scarlett Johansson and Bill Murray are lost in translation	','https://www.youtube.com/watch?v=W6iVPCRflQM','2023-11-12 00:00:00','07955104-4e23-4d0a-9e02-6bb7fdbce046'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','Ada Apa Dengan Cinta?','Cinta, seorang remaja di pinggiran kota Jakarta.','Indonesia','a teenager in suburban Jakarta, spends all of her time with her four friends -- that is, until she falls for Rangga        ','https://www.youtube.com/watch?v=mSZ-ySRW29k','2020-09-12 00:00:00','4b063c20-b8fe-4e61-b58b-2ab2b2a4925e'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62','Laskar Pelangi','Two Indonesian teachers embrace an inspiring crop of gifted young students who''ve come to study at their crumbling Islamic primary school.','Indonesia','Two Indonesian teachers embrace an inspiring crop of gifted young students who''ve come to study at their crumbling Islamic primary school.','https://www.youtube.com/watch?v=e1SxNP7PWAc','2022-09-28 00:00:00','6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','The Social Network','Pada tahun 2003, mahasiswa Harvard dan jenius komputer Mark Zuckerberg mulai mengerjakan konsep baru yang akhirnya berubah menjadi jaringan sosial global.','Amerika Serikat','You don''t get 500 million friends without making a few enemies.	','https://www.youtube.com/watch?v=lB95KLmpLR4','2023-02-21 00:00:00','533716f2-6978-4ca5-9b6a-1e5db02d732f'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','Get Out','Sekarang Chris dan pacarnya, Rose, telah mencapai tahap pertemuan dengan orang tua dalam berpacaran.','Amerika Serikat','A young African American man visits his Caucasian girlfriend''s cursed family estate.	','https://www.youtube.com/watch?v=DzfpyUB60YY','2021-09-21 00:00:00','c7d7ee5c-0754-4667-bb8e-9cc63a57d79e'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4','Fight Club','Seorang pria depresi (Edward Norton) yang menderita insomnia bertemu dengan seorang penjual sabun aneh bernama Tyler Durden.','Amerika Serikat','The first rule of Fight Club is...','https://www.youtube.com/watch?v=BdJKm16Co6M','2022-02-01 00:00:00','1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a','Gie','Gie adalah sebuah film biopik Indonesia tahun 2005 yang disutradarai oleh Riri Riza. Film ini bercerita tentang Soe Hok Gie.','Indonesia','Based on the Journal of Soe Hok Gie, an activist in Indonesia, who feels he is falling apart and fears his efforts has caused the death of millions.','https://www.youtube.com/watch?v=t3k41Px7LGg','2021-12-05 00:00:00','52854e69-d59c-4db8-a55a-2f1a69ecec01');


INSERT INTO FILM VALUES ('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','https://www.pacilflix.com/jurassic-park','1993-06-11 00:00:00','127'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','https://www.pacilflix.com/superbad','2007-08-17 00:00:00','113'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','https://www.pacilflix.com/her','2013-10-12 00:00:00','126'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551','https://www.pacilflix.com/lost-in-translation','2003-09-18 00:00:00','102'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','https://www.pacilflix.com/ada-apa-dengan-cinta','2002-02-08 00:00:00','112'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62','https://www.pacilflix.com/laskar-pelangi','2008-09-26 00:00:00','124'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','https://www.pacilflix.com/the-social-network','2010-10-01 00:00:00','120'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','https://www.pacilflix.com/get-out','2017-01-23 00:00:00','104'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4','https://www.pacilflix.com/fight-club','1999-10-15 00:00:00','139'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a','https://www.pacilflix.com/gie','2005-04-14 00:00:00','147');


INSERT INTO SERIES VALUES ('d2718217-0546-4b92-9c3f-4e71b31d85d8'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e');


INSERT INTO EPISODE VALUES ('d2718217-0546-4b92-9c3f-4e71b31d85d8','The One Where Monica Gets a Roommate (Pilot)','Rachel lari dari pernikahannya dan bertemu sahabatnya di kedai kopi. Ross depresi karena perceraiannya, tetapi ia masih menyukai Rachel.',22,'https://www.pacilflix.com/friends/season-1/eps/1/','1994-09-22 00:00:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','"The One with the Sonogram at the End"','Mantan istri Ross yang lesbian tengah mengandung anaknya, dan Ross tidak suka dengan pilihan nama belakang untuk bayinya.',22,'https://www.pacilflix.com/friends/season-1/eps/2/','1994-09-29 00:00:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','"The Seinfeld Chronicles"','Wanita yang berkenalan dengan Jerry di Michigan kini terbang ke New York dan ingin tinggal bersamanya, tetapi Jerry tak yakin apakah itu keinginan romantis atau tidak.',23,'https://www.pacilflix.com/seinfeld/season-1/eps/1/','1989-07-05 00:00:00'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','"Pilot"','Kru dokumenter memberikan pengenalan langsung kepada staf Perusahaan Kertas Dunder Mifflin cabang Scranton , yang dikelola oleh Michael Scott .',22,'https://www.pacilflix.com/the-office/season-1/eps/1/','2005-03-24 00:00:00'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','"The Tagger"','Jake ditugaskan menangani kasus grafiti kecil sebagai hukuman karena terlambat dalam apel.',21,'https://www.pacilflix.com/brooklyn-nine-nine/season-1/eps/2/','2013-09-17 00:00:00'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','"Pilot bagian 1 & 2"','Karena promosi Harvey mengharuskannya merekrut lulusan Hukum Harvard, maka dia memilih Mike Ross. Tetapi ternyata Mike bukanlah sarjana hukum',81,'https://www.pacilflix.com/suits/season-1/eps/1/','2011-06-23 00:00:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','"The One with the Thumb"','Perusahaan minuman bersoda memberi Phoebe US$7000 setelah ia menemukan potongan jari di dalam kaleng soda.',22,'https://www.pacilflix.com/friends/season-1/eps/3/','1994-10-06 00:00:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','"The Stake Out"','Baru saja putus dari Elaine, Jerry berkenalan dengan seorang wanita di sebuah pesta. Namun, ia hanya mendapat info kantornya sehingga ia harus mengintai tempat itu.',23,'https://www.pacilflix.com/seinfeld/season-1/eps/2/','1990-05-31 00:00:00'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','"Diversity Day"','Peniruan kontroversial Michael terhadap rutinitas Chris Rock memaksa staf untuk menjalani seminar keragaman ras.',22,'https://www.pacilflix.com/the-office/season-1/eps/2/','2005-03-29 00:00:00'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','"The Slump"','Kasus yang tak bisa Jake pecahkan makin menumpuk dan detektif lain takut hal ini menular pada mereka, sedangkan Amy harus mengelola program bagi remaja bermasalah.',21,'https://www.pacilflix.com/brooklyn-nine-nine/season-1/eps/3/','2013-10-01 00:00:00'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','"Errors and Omissions"','Sebuah kasus yang sangat gampang berubah menjadi runyam ketika Harvey dituduh hakim melakukan hubungan tak layak pada istrinya.',43,'https://www.pacilflix.com/suits/season-1/eps/2/','2011-06-30 00:00:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','"The One with George Stephanopoulos"','Seorang kurir tak sengaja mengantarkan pizza yang ditujukan untuk George Stephanopoulos, yang tinggal di seberang jalan tempat tinggal para gadis.',22,'https://www.pacilflix.com/friends/season-1/eps/4/','1994-10-13 00:00:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','"The Robbery"','Apartemen Jerry dirampok. Akibatnya, kini ia ingin pindah rumah dan memberikan rumahnya kepada Elaine saja.',23,'https://www.pacilflix.com/seinfeld/season-1/eps/3/','1990-06-07 00:00:00');


INSERT INTO PENGGUNA VALUES ('andikusnadi11','Th3Q!ckF0x','d2718217-0546-4b92-9c3f-4e71b31d85d8','Indonesia'),
	('budibudiman22','$trongP@ss22','a6b173b9-0b0e-4edb-b685-219bf9f9cc02','Indonesia'),
	('cahyapurnomo33','S3cur3Pa$$w0rd','fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','Indonesia'),
	('dindaandriani44','My_P@ssw0rd44','eece58e2-80b8-47bb-b8be-9f287b69d042','Indonesia'),
	('ekosetiawan55','Saf3tyF1r$t55','5acdfabf-7372-4e7f-a287-bf6f47efc99e','Indonesia'),
	('fikrihidayat66','Th3B3stKey66','a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','Indonesia'),
	('gustibagus77','P@ssw0rd_!t!77','d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','Indonesia'),
	('harunmaseko88','R3liabl3K3y88','e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','Indonesia');


INSERT INTO PERUSAHAAN_PRODUKSI VALUES ('Warner Bros. Television'),
	('Castle Rock Entertainment'),
	('NBCUniversal'),
	('Universal Television'),
	('Universal Cable Productions'),
	('Amblin Entertainment'),
	('Columbia Pictures'),
	('Annapurna Pictures'),
	('Miles Films'),
	('Blumhouse Productions'),
	('20th Century Fox'),
	('Miramax Films'),
	('MGM (Metro-Goldwyn-Mayer)'),
	('Lucasfilm'),
	('The Weinstein Company');


INSERT INTO PAKET VALUES
	('basic', 50000 , 720 ),
	('standard', 65000 , 1080),
	('premium', 80000 , 4000);


INSERT INTO DUKUNGAN_PERANGKAT VALUES ('basic','ponsel'),
	('standard','ponsel'),
	('standard','komputer'),
	('standard','tablet'),
	('premium','ponsel'),
	('premium','komputer'),
	('premium','tablet'),
	('premium','televisi');


INSERT INTO DAFTAR_FAVORIT VALUES ('2023-06-21 00:00:00','andikusnadi11','Suits'),
	('2024-03-09 00:00:00','andikusnadi11','Fight Club'),
	('2024-03-30 00:00:00','andikusnadi11','Laskar Pelangi'),
	('2024-02-02 00:00:00','budibudiman22','Jurassic Park'),
	('2024-04-19 00:00:00','budibudiman22','Friends'),
	('2023-05-28 00:00:00','cahyapurnomo33','Ada Apa Dengan Cinta?'),
	('2023-11-14 00:00:00','dindaandriani44','Seinfeld'),
	('2023-08-21 00:00:00','dindaandriani44','Lost in Translation'),
	('2024-04-13 00:00:00','fikrihidayat66','Gie'),
	('2023-11-07 00:00:00','fikrihidayat66','Brooklyn Nine-Nine'),
	('2023-12-27 00:00:00','fikrihidayat66','Get Out'),
	('2023-05-01 00:00:00','fikrihidayat66','The Office'),
	('2023-08-07 00:00:00','gustibagus77','The Social Network'),
	('2023-11-26 00:00:00','gustibagus77','Superbad'),
	('2023-08-27 00:00:00','harunmaseko88','Her'),
	('2023-11-19 00:00:00','harunmaseko88','Suits');


INSERT INTO TAYANGAN_MEMILIKI_DAFTAR_FAVORIT VALUES ('5acdfabf-7372-4e7f-a287-bf6f47efc99e','2023-06-21 00:00:00','andikusnadi11'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4','2024-03-09 00:00:00','andikusnadi11'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62','2024-03-30 00:00:00','andikusnadi11'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','2024-02-02 00:00:00','budibudiman22'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','2024-04-19 00:00:00','budibudiman22'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','2023-05-28 00:00:00','cahyapurnomo33'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','2023-11-14 00:00:00','dindaandriani44'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551','2023-08-21 00:00:00','dindaandriani44'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a','2024-04-13 00:00:00','fikrihidayat66'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','2023-11-07 00:00:00','fikrihidayat66'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','2023-12-27 00:00:00','fikrihidayat66'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','2023-05-01 00:00:00','fikrihidayat66'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','2023-08-07 00:00:00','gustibagus77'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','2023-11-26 00:00:00','gustibagus77'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','2023-08-27 00:00:00','harunmaseko88'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','2023-11-19 00:00:00','harunmaseko88');


INSERT INTO MEMAINKAN_TAYANGAN VALUES ('d2718217-0546-4b92-9c3f-4e71b31d85d8','6e737d14-7189-4952-9673-f39f53931e2c'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','966cb526-b850-41e9-879a-eb525855304f'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','cf410683-bd1a-4b6b-9c37-aa6df5c7cd3a'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','0d97370e-b604-478e-87bd-cadf747e36f7'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','e572cbab-f064-431a-b777-e1f66ca93db9'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','a239dfed-e7a7-451b-aabc-68e8e97f7d53'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','d503fc33-e369-498e-b304-73acdf682d39'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','4c802e3c-05ed-43c4-934a-e79d28da2ad1'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','8b26a793-181b-47f0-8527-5ad421f6f08b'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','5622077f-f3bd-45b5-87ff-4ab8cba74866'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','e191701b-ea7f-46e3-b1cb-a574d59cd316'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','fe88c2bb-a53f-4cf8-888a-2adfa4f9a8ec'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','16eb8ca6-d8b0-4d02-b9c2-6403824d1bc6'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','432c0e4d-e426-4359-af31-05ab6e00be9c'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','8d3feba0-234a-4116-82da-269aefc8f59d'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','1b33c919-760c-4611-848a-b4f521c27a00'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','12f40471-e20e-45b8-836e-0ccfbd61cf74'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','fb1504d7-a3ca-4631-a790-d9e9dc4ad33d'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','abe8d13e-4f7d-4cee-a42d-10b6f5f86dd8'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','5bc3ad0a-73f3-47d2-bbb5-96804277ba26'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','b2fd8497-c91e-49b4-9368-add6eb4fd25b'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','0b7148c1-0aed-4cdc-ae04-063935fb1700'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','be747bb7-1651-4d24-9115-73bf55f6c6f0'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','67558cfd-d7a8-4b45-9f4b-a6025b2e7c9e'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','3bfe2712-3f91-436f-9368-e73639f09bf0'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551','48e67063-99f3-442c-9824-4ace71571f1f'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551','c2dba860-801f-40d7-a24d-9cc405985b24'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','fb9266e5-65d1-4f37-93ef-157b1d7d76e9'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','c30b7675-cccc-40e4-8501-73b75f9a6646'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','f638a046-8260-4587-8154-875b39480c10'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62','6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62','52854e69-d59c-4db8-a55a-2f1a69ecec01'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','9db6acea-56be-45a0-9df0-6e7a9d09a3c6'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','07955104-4e23-4d0a-9e02-6bb7fdbce046'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','e59939ff-9324-4e7d-bc4f-3f39aef5159b'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','913af2e5-a04d-4e2b-81c8-c7b83f6cd1db'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4','2f57132c-cb3d-4d1c-a999-59ac18cbe770'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4','27d238d7-39b4-4385-8515-914056f0d3b3'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a','b65817b4-2b56-4e3c-b3b1-6094ed5cfd8c');




INSERT INTO GENRE_TAYANGAN VALUES ('d2718217-0546-4b92-9c3f-4e71b31d85d8','Fantasy, Drama, Animation'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','Animation, Thriller, Action, Comedy'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','Animation, Comedy'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','Animation, Drama'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','Fantasy, Comedy, Science Fiction'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','Science Fiction, Drama'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','Science Fiction, Comedy, Action'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','Fantasy, Action'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551','Animation, Action, Documentary'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','Mystery, Fantasy, Romance, Drama');


INSERT INTO TRANSACTION VALUES ('andikusnadi11','2024-01-01','2024-02-01','basic','Transfer Bank','2024-01-01 22:40:05'),
	('budibudiman22','2024-03-02','2024-04-02','basic','Transfer Bank','2024-03-02 16:40:05'),
	('cahyapurnomo33','2024-04-03','2024-05-03','basic','E-wallet','2024-04-03 18:30:00'),
	('dindaandriani44','2024-05-04','2024-06-04','premium','Transfer Bank','2024-05-04 13:00:00'),
	('ekosetiawan55','2024-06-05','2024-07-05','standard','Transfer Bank','2024-06-05 10:15:00'),
	('fikrihidayat66','2024-07-06','2024-08-06','standard','Transfer Bank','2024-07-06 11:00:00'),
	('gustibagus77','2024-07-07','2024-08-07','premium','E-wallet','2024-07-07 12:00:14'),
	('harunmaseko88','2024-08-08','2024-09-08','premium','E-wallet','2024-08-08 18:15:00'),
	('andikusnadi11','2024-02-02','2024-03-02','premium','Transfer Bank','2024-02-02 10:00:00'),
	('budibudiman22','2024-05-03','2024-06-03','standard','Transfer Bank','2024-05-03 11:10:11'),
	('cahyapurnomo33','2024-05-05','2024-06-05','standard','E-wallet','2024-05-05 20:00:00'),
	('dindaandriani44','2024-06-07','2024-07-07','premium','Transfer Bank','2024-06-07 19:18:10'),
	('ekosetiawan55','2024-08-06','2024-09-06','standard','Transfer Bank','2024-08-06 12:00:00'),
	('fikrihidayat66','2024-08-07','2024-09-07','standard','Transfer Bank','2024-08-07 19:00:45'),
	('gustibagus77','2024-08-09','2024-09-09','premium','E-wallet','2024-08-09 16:17:18'),
	('harunmaseko88','2024-09-09','2024-10-09','premium','E-wallet','2024-09-09 10:11:20'),
	('andikusnadi11','2024-03-03','2024-04-03','premium','Transfer Bank','2024-03-03 15:20:11'),
	('budibudiman22','2024-06-04','2024-07-04','premium','Transfer Bank','2024-06-04 10:10:10'),
	('cahyapurnomo33','2024-06-06','2024-07-06','standard','E-wallet','2024-06-06 11:25:10'),
	('dindaandriani44','2024-07-08','2024-08-08','premium','Transfer Bank','2024-07-08 23:10:11'),
	('ekosetiawan55','2024-09-07','2024-10-07','premium','Transfer Bank','2024-09-07 10:18:20'),
	('fikrihidayat66','2024-09-08','2024-10-08','premium','Transfer Bank','2024-09-08 18:22:22'),
	('gustibagus77','2024-09-10','2024-10-10','standard','E-wallet','2024-09-10 19:00:27'),
	('harunmaseko88','2024-10-10','2024-11-10','basic','E-wallet','2024-10-10 14:00:14');


INSERT INTO PERSETUJUAN VALUES ('Warner Bros. Television','d2718217-0546-4b92-9c3f-4e71b31d85d8','2023-06-14 00:00:00','730','120000000','2023-08-14 00:00:00'),
	('Warner Bros. Television','a6b173b9-0b0e-4edb-b685-219bf9f9cc02','2021-10-27 00:00:00','450','280000000','2022-04-27 00:00:00'),
	('Warner Bros. Television','fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','2020-11-03 00:00:00','365','85000000','2021-01-03 00:00:00'),
	('Castle Rock Entertainment','eece58e2-80b8-47bb-b8be-9f287b69d042','2022-02-14 00:00:00','1095','650000000','2022-05-14 00:00:00'),
	('Castle Rock Entertainment','5acdfabf-7372-4e7f-a287-bf6f47efc99e','2020-07-18 00:00:00','365','320000000','2020-09-18 00:00:00'),
	('NBCUniversal','a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','2019-01-10 00:00:00','1096','150000000','2019-04-10 00:00:00'),
	('NBCUniversal','d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','2023-03-28 00:00:00','1826','720000000','2023-07-28 00:00:00'),
	('Universal Television','e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','2019-03-27 00:00:00','365','200000000','2019-06-27 00:00:00'),
	('Universal Cable Productions','ed314b2f-59a7-4d77-b7b1-3a91f66c4551','2023-01-06 00:00:00','1460','180000000','2023-06-06 00:00:00'),
	('Amblin Entertainment','1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','2020-12-17 00:00:00','365','105000000','2021-03-17 00:00:00'),
	('Columbia Pictures','748f1f54-38f3-4d72-9ecb-2b17f5e77f62','2021-03-21 00:00:00','400','270000000','2021-11-21 00:00:00'),
	('Annapurna Pictures','d78345c5-09d3-42e1-ae7b-9f4b66e3e739','2019-11-29 00:00:00','1095','560000000','2020-07-29 00:00:00'),
	('Miles Films','7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','2019-07-19 00:00:00','1460','1200000000','2020-02-19 00:00:00'),
	('Blumhouse Productions','5e0ff90f-474d-42c4-8581-04736b5a01d4','2022-02-09 00:00:00','1460','210000000','2022-10-09 00:00:00'),
	('20th Century Fox','bc283c51-c0f9-4e73-9138-3d354bd1d50a','2022-05-31 00:00:00','730','100000000','2022-12-31 00:00:00'),
	('Miramax Films','a6b173b9-0b0e-4edb-b685-219bf9f9cc02','2023-08-25 00:00:00','1095','1500000000','2023-11-25 00:00:00'),
	('MGM (Metro-Goldwyn-Mayer)','fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','2022-12-05 00:00:00','1460','620000000','2023-10-05 00:00:00'),
	('Lucasfilm','5acdfabf-7372-4e7f-a287-bf6f47efc99e','2022-09-06 00:00:00','1095','880000000','2023-05-06 00:00:00'),
	('The Weinstein Company','e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','2021-04-30 00:00:00','1826','750000000','2022-02-28 00:00:00'),
	('Annapurna Pictures','1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','2023-08-19 00:00:00','730','520000000','2024-03-19 00:00:00');


INSERT INTO TAYANGAN_TERUNDUH VALUES ('5acdfabf-7372-4e7f-a287-bf6f47efc99e','ekosetiawan55','2021-07-08 00:00:00'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','budibudiman22','2023-06-11 00:01:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','dindaandriani44','2023-03-30 00:02:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','fikrihidayat66','2023-08-31 00:03:00'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','harunmaseko88','2023-11-08 00:04:00'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','andikusnadi11','2023-02-08 00:05:00'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','harunmaseko88','2022-01-27 00:06:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','budibudiman22','2023-03-10 00:07:00'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','andikusnadi11','2023-11-12 00:08:00'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','fikrihidayat66','2020-09-12 00:09:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','ekosetiawan55','2022-09-28 00:10:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','ekosetiawan55','2023-02-21 00:11:00'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','cahyapurnomo33','2021-09-21 00:12:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','dindaandriani44','2022-02-01 00:13:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','dindaandriani44','2021-12-05 00:14:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','fikrihidayat66','2021-07-08 00:15:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','cahyapurnomo33','2023-06-11 00:16:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','ekosetiawan55','2023-03-30 00:17:00'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','fikrihidayat66','2023-08-31 00:18:00'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','harunmaseko88','2023-11-08 00:19:00'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','fikrihidayat66','2023-02-08 00:20:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','budibudiman22','2022-01-27 00:21:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','cahyapurnomo33','2023-03-10 00:22:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','cahyapurnomo33','2023-11-12 00:23:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','budibudiman22','2020-09-12 00:24:00'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','dindaandriani44','2022-09-28 00:25:00'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8','cahyapurnomo33','2023-02-21 00:26:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','budibudiman22','2021-09-21 00:27:00'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','dindaandriani44','2022-02-01 00:28:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','cahyapurnomo33','2021-12-05 00:29:00'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','harunmaseko88','2021-07-08 00:30:00'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','cahyapurnomo33','2023-06-11 00:31:00'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','ekosetiawan55','2023-03-30 00:32:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','ekosetiawan55','2023-08-31 00:33:00'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','harunmaseko88','2023-11-08 00:34:00'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','harunmaseko88','2023-02-08 00:35:00');


INSERT INTO ULASAN VALUES ('d2718217-0546-4b92-9c3f-4e71b31d85d8','andikusnadi11','2024-03-17 13:44:09',8,'Tayangan ini benar-benar menarik. Harus ditonton untuk semua orang!'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02','budibudiman22','2024-02-03 08:29:42',7,'Tayangan ini cukup menarik.'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56','cahyapurnomo33','2024-09-28 18:22:36',7,'Saya cukup menikmati tayangan ini'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042','dindaandriani44','2024-05-18 19:17:21',6,'Saya menemukan tayangan ini cukup membosankan.'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e','ekosetiawan55','2024-04-05 14:34:51',9,'Tayangan ini luar biasa dengan plot yang mendebarkan dan karakter-karakter yang kompleks. Saya tidak sabar untuk menonton lebih banyak!'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d','fikrihidayat66','2024-07-20 06:57:26',8,'Dengan visual yang mengagumkan dan plot yang menarik, tayangan ini berhasil menarik saya ke dalam dunianya. '),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8','gustibagus77','2024-08-12 12:08:13',8,'Saya sangat menikmati tayangan ini dan menemukan bahwa cerita serta karakter-karakternya sangat memikat.'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd','harunmaseko88','2024-08-15 23:15:46',7,'Tayangan ini memiliki potensi besar, tetapi gagal memberikan.'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551','andikusnadi11','2024-10-04 09:29:03',7,'Tayangan ini menarik perhatian saya dengan konsep yang unik dan eksekusi yang baik. Sangat direkomendasikan untuk ditonton!'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e','budibudiman22','2024-07-16 04:42:02',8,'Dengan alur cerita yang menarik dan karakter-karakter yang berkesan, tayangan ini berhasil memikat saya sejak awal hingga akhir.'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62','cahyapurnomo33','2024-08-03 18:59:21',8,'Tayangan ini menyajikan pengalaman yang menyenangkan dengan cerita yang menarik dan penuh dengan kejutan.'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','dindaandriani44','2024-03-02 15:22:03',9,'Saya sangat terkesan dengan tayangan ini karena kesederhanaan ceritanya dan pesan yang disampaikannya.'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','ekosetiawan55','2024-02-24 02:40:45',9,'Dengan alur cerita yang menggugah dan karakter-karakter yang kuat, tayangan ini adalah salah satu yang terbaik yang pernah saya tonton.'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4','fikrihidayat66','2024-01-22 01:08:38',8,'Tayangan ini sangat menghibur dengan cerita yang menarik dan visual yang memukau. Sangat direkomendasikan!'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a','gustibagus77','2024-07-23 09:50:36',8,'Meskipun tidak sempurna, tayangan ini tetap menghibur dengan humor yang khas dan karakter-karakter yang menggemaskan.'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62','harunmaseko88','2024-11-02 03:03:51',7,'Saya menikmati tayangan ini meskipun ada beberapa kelemahan dalam pengembangan ceritanya. Namun, keseluruhan pengalaman menontonnya tetap memuaskan.'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739','andikusnadi11','2024-12-02 06:15:37',6,'Dengan alur cerita yang menarik dan karakter-karakter yang kompleks, tayangan ini berhasil menarik perhatian saya dari awal hingga akhir. '),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35','budibudiman22','2024-09-20 17:36:38',6,'Meskipun tidak sempurna, tayangan ini tetap menghibur dengan cerita yang menyentuh dan karakter-karakter yang kuat.'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4','cahyapurnomo33','2024-12-08 05:51:43',8,'Tayangan ini menawarkan pengalaman yang menyenangkan dengan alur cerita yang menarik dan karakter-karakter yang kuat.'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a','dindaandriani44','2024-10-17 22:29:18',8,'Dengan cerita yang menghibur dan karakter-karakter yang kuat, tayangan ini cocok untuk ditonton di akhir pekan yang santai.');


INSERT INTO MENULIS_SKENARIO_TAYANGAN VALUES('d2718217-0546-4b92-9c3f-4e71b31d85d8', '6d0e5d1c-53dd-48e4-ace8-5a123fdae30f'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02', '52854e69-d59c-4db8-a55a-2f1a69ecec01'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56', '9db6acea-56be-45a0-9df0-6e7a9d09a3c6'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042', '1fb310e3-8b9d-4efe-aced-2b599c7185b9'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e', '07955104-4e23-4d0a-9e02-6bb7fdbce046'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d', '59988ac6-7dfa-40e6-aee6-4a89d02e94f2'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8', '1f60851a-62d4-4913-a07e-a6450ca0dfd4'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd', '3dd54242-7e3a-41ea-a555-0ba5360e0d2e'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551', 'ebae3d7a-171d-4864-9da2-dbc637b895f4'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e', 'f4070bb9-49ca-44dc-a2c7-d9bb6427c29a'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62', 'c80e7251-27bf-4632-8206-1bf70f03ac5d'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739', 'e68f6dd5-2b78-43f5-9633-8ff6a7a87595'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35', 'f33c0bb6-9689-4b05-b9b5-47c034768b4d'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4', 'f47e951a-abe8-4413-954e-18f32957a88e'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a', '5854667f-dbf6-4863-9ec9-10bc6a3248ad'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8', '9963b673-2cb4-4768-80e6-816420bdf06f'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02', '2bf07ea8-f20d-43b5-91bc-2147e17fce8c'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56', 'de0c3690-c706-40b2-a335-d8130c3aa03d'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042', '2fc4362a-9252-4809-8406-562e7c3dcf50'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e', '3a5a3641-2115-42dd-8e96-c24d2289b0bd'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d', 'cb5d214c-4733-4aa5-96e5-65aae576e107'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8', '705e14c8-96fc-4302-a637-46b242c6071d'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd', 'fd1e1220-e450-469a-b5ab-9dacf7b4196a'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551', 'ff4623ab-ab1a-4113-a563-d0f726e3f628'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e', '84ca57d2-308d-4143-b5bb-42c0c186b158'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62', 'e59939ff-9324-4e7d-bc4f-3f39aef5159b'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739', '913af2e5-a04d-4e2b-81c8-c7b83f6cd1db'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35', '2f57132c-cb3d-4d1c-a999-59ac18cbe770'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4', '27d238d7-39b4-4385-8515-914056f0d3b3'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a', 'b65817b4-2b56-4e3c-b3b1-6094ed5cfd8c'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8', 'b65817b4-2b56-4e3c-b3b1-6094ed5cfd8c'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02', '27d238d7-39b4-4385-8515-914056f0d3b3'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56', '2f57132c-cb3d-4d1c-a999-59ac18cbe770'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042', '913af2e5-a04d-4e2b-81c8-c7b83f6cd1db'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e', '913af2e5-a04d-4e2b-81c8-c7b83f6cd1db');


INSERT INTO RIWAYAT_NONTON VALUES('5acdfabf-7372-4e7f-a287-bf6f47efc99e', 'andikusnadi11', '2023-01-16', '2023-06-21'),
	('5e0ff90f-474d-42c4-8581-04736b5a01d4', 'andikusnadi11', '2024-03-09', '2024-03-09'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d', 'andikusnadi11', '2024-03-29', '2024-03-30'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d', 'andikusnadi11', '2023-02-20', '2023-02-21'),
	('a29bd1f2-c6b1-44c7-8a76-f9bd9b054f4d', 'budibudiman22', '2024-01-30', '2024-02-01'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8', 'budibudiman22', '2024-01-03', '2024-04-19'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e', 'budibudiman22', '2023-04-30', '2023-05-20'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02', 'budibudiman22', '2023-06-15', '2023-08-14'),
	('1e14c7e5-2b2f-4535-b2c8-3d6fbbda3e1e', 'cahyapurnomo33', '2023-05-28', '2023-05-28'),
	('d2718217-0546-4b92-9c3f-4e71b31d85d8', 'cahyapurnomo33', '2023-01-02', '2024-04-08'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35', 'cahyapurnomo33', '2023-10-20', '2023-10-21'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739', 'cahyapurnomo33', '2023-06-07', '2023-06-07'),
	('a6b173b9-0b0e-4edb-b685-219bf9f9cc02', 'dindaandriani44', '2023-02-06', '2023-10-12'),
	('ed314b2f-59a7-4d77-b7b1-3a91f66c4551', 'dindaandriani44', '2023-08-15', '2023-08-18'),
	('bc283c51-c0f9-4e73-9138-3d354bd1d50a', 'fikrihidayat66', '2024-04-09', '2024-04-13'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042', 'fikrihidayat66', '2023-11-01', '2023-11-07'),
	('7b8e09af-3e59-45a4-8f2d-39dc3e7b0f35', 'fikrihidayat66', '2023-12-26', '2023-12-26'),
	('fbc83b1f-d5f6-46c9-a527-6c29c2a73e56', 'fikrihidayat66', '2023-01-02', '2023-05-01'),
	('d78345c5-09d3-42e1-ae7b-9f4b66e3e739', 'gustibagus77', '2023-08-07', '2023-08-07'),
	('d749f65b-b3c4-4b07-8cbd-4d0cbe9b68a8', 'gustibagus77', '2023-11-20', '2023-11-21'),
	('748f1f54-38f3-4d72-9ecb-2b17f5e77f62', 'gustibagus77', '2023-01-20', '2023-01-21'),
	('e7cdd2bd-5f08-4f12-9073-4e5ae9d4d7fd', 'harunmaseko88', '2023-08-26', '2023-08-26'),
	('5acdfabf-7372-4e7f-a287-bf6f47efc99e', 'harunmaseko88', '2023-07-21', '2023-11-17'),
	('eece58e2-80b8-47bb-b8be-9f287b69d042', 'harunmaseko88', '2023-02-06', '2024-08-29');
