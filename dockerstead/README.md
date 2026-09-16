# DockerStead

DockerStead 是当前 `Homestead.yaml` 的 Docker 版本。本目录包含运行所需的全部配置，不修改现有 Vagrant/Homestead 环境。

## 环境组成

- Nginx，支持 HTTP/HTTPS 和 `.testing` 多站点。
- 一个参数化 `Dockerfile`，分别构建 PHP-FPM 7.4、8.0、8.1、8.2、8.3、8.4、8.5 镜像。
- PHP 7.4 镜像额外安装兼容的 Swoole 4.8.13 扩展。
- 一个参数化 `Frankenfile`，分别构建 FrankenPHP 8.2、8.3、8.4、8.5 镜像，并以独立 HTTP 服务提供。
- Composer 2，以及 Laravel 常用的 MySQL、PostgreSQL、Redis、GD、Intl、Zip、Bcmath 等 PHP 扩展。
- MySQL 8.4、PostgreSQL 17、Redis 7、Memcached、Mailpit、MinIO、Meilisearch、Elasticsearch、MongoDB 和 Adminer。

默认启动 Homestead 常用的 Web、PHP、FrankenPHP、数据库、缓存和邮件服务。FrankenPHP 默认映射到宿主机 `8082`–`8085` 端口，可通过 `.env` 中的 `FRANKENPHP82_PORT`–`FRANKENPHP85_PORT` 修改。每个 FrankenPHP 容器都挂载 `CODE_PATH`，默认文档根目录为 `/home/vagrant/code`，也可通过 `FRANKENPHP_ROOT` 指定单个项目的 `public` 目录。MinIO、Meilisearch、Elasticsearch、MongoDB 属于 `optional` profile，需要时运行：

```powershell
docker compose -f docker-compose.yaml --profile optional up -d
```

每个站点使用哪个 PHP 版本由 `nginx/conf.d/default.conf` 中的 `$dockerstead_php` 映射决定。当前映射已按仓库根目录的 `Homestead.yaml` 生成；全部站点清单也保存在 `sites.yaml` 中。

## 启动

需要先安装并启动 Docker Desktop（Linux 下安装 Docker Engine 和 Compose 插件）。在 PowerShell 中运行：

```powershell
Set-Location D:\Homestead\dockerstead
Copy-Item .env.example .env
.\dockerstead.ps1 build
.\dockerstead.ps1 up
.\dockerstead.ps1 ps
```

Linux、macOS 或 WSL：

```bash
cd dockerstead
cp .env.example .env
bash ./dockerstead build
bash ./dockerstead up
```

首次构建七个 PHP 版本会下载并编译扩展，需要较长时间。后续构建会复用 Docker 缓存。

## 本机配置

默认把宿主机 `D:/Code` 挂载到容器 `/home/vagrant/code`。路径或端口不一致时修改 `.env`。HTTPS 默认读取 `../.certificates/homestead.crt` 和 `homestead.key`，对应当前 Homestead 的证书设置。

将 `hosts.txt` 中除 `localhost` 外的内容追加到 Windows 的 `C:\Windows\System32\drivers\etc\hosts`（需要管理员权限），或追加到 Linux/macOS 的 `/etc/hosts`。

常用入口：

| 服务 | 地址/端口 |
| --- | --- |
| 站点 | `http://<站点域名>` / `https://<站点域名>` |
| Adminer | `http://localhost:8080` |
| Mailpit | `http://localhost:8025` |
| MinIO Console | `http://localhost:9001` |
| MySQL | `127.0.0.1:3306`，`homestead/secret` |
| PostgreSQL | `127.0.0.1:5432`，`homestead/secret` |
| Redis | `127.0.0.1:6379` |

容器内应用应使用 Compose 服务名连接依赖，例如 `DB_HOST=mysql`、`REDIS_HOST=redis`、`MAIL_HOST=mailpit`，不要使用 `127.0.0.1`。

## 常用命令

```powershell
# 进入指定 PHP 容器
.\dockerstead.ps1 shell php74
.\dockerstead.ps1 shell php83
.\dockerstead.ps1 shell frankenphp83

# 在指定 PHP 版本中运行 Composer
.\dockerstead.ps1 composer php83 install

# 查看日志和停止环境
.\dockerstead.ps1 logs nginx
.\dockerstead.ps1 down
```

直接使用 Compose 也可以：

```powershell
docker compose -f docker-compose.yaml build php74 php83
docker compose -f docker-compose.yaml up -d
docker compose -f docker-compose.yaml exec php83 php -v
docker compose -f docker-compose.yaml exec frankenphp83 php -v
```

删除数据卷会永久移除 DockerStead 的数据库和对象存储数据：

```powershell
docker compose -f docker-compose.yaml down -v
```

## 增加站点

在 `sites.yaml` 中记录站点，并在 `nginx/conf.d/default.conf` 的两个 `map` 块中分别增加文档根目录和 PHP 上游。例如：

```nginx
map $host $dockerstead_root {
    demo.testing /home/vagrant/code/demo/public;
}
map $host $dockerstead_php {
    demo.testing php82:9000;
}
```

随后在 hosts 文件中把域名指向 `127.0.0.1`，执行 `.\dockerstead.ps1 restart`。
