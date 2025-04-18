<a href="https://www.mozilla.org/en-US/MPL/2.0" rel="nofollow"><img src="https://camo.githubusercontent.com/3fcf3d6b678ea15fde3cf7d6af0e242160366282d62a7c182d83a50bfee3f45e/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f4d504c2d322e302d626c75652e737667" alt="License: MPL-2.0" data-canonical-src="https://img.shields.io/badge/MPL-2.0-blue.svg" style="max-width:100%;"></a>
![love-badge]

![GitHub-Mark-Light](https://user-images.githubusercontent.com/1947905/229085401-96e7dd95-99a1-4781-b514-e4cd8614fa57.png#gh-light-mode-only)
![GitHub-Mark-Dark](https://user-images.githubusercontent.com/1947905/229466140-9227de8a-4889-4512-857a-86a2a4bc15a9.png#gh-dark-mode-only)

<div align="center">
    <a href="https://community.taiga.io/"><b>Community</b></a> •
    <a href="https://twitter.com/taigaio"><b>Twitter</b></a> •
    <a href="https://www.instagram.com/taiga.io/"><b>Instagram</b></a> •
    <a href="https://www.linkedin.com/company/2477837"><b>Linkedin</b></a> •
    <a href="https://www.youtube.com/channel/UCPylOFXlUHW55ErP8q2R2DQ/videos"><b>Youtube</b></a>
</div>

<details open="open">
  <summary>Table of Contents</summary>

- [About](#about)
  - [Built with](#built-with)
- [Running the Project](#running-the-project)
  - [Using Docker (Production-like Environment)](#using-docker-production-like-environment)
  - [Development Setup](#development-setup)
- [Community](#community)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

</details>

## About

[Taiga](https://www.taiga.io/) is a free and open-source project management tool for cross-functional agile teams to work effectively. 

![taiga-projects-homepage](https://github.com/taigaio/taiga/assets/5446186/b9dc7f21-c670-44bf-ae1f-e5a41343dffc)


This is the repository of the next iteration of Taiga in which we are keeping key Taiga concepts but rethinking many aspects related to user experience, processes and interaction. The new Taiga will also showcase the [Kaleidos](https://kaleidos.net/) vision around lean and design processes, connecting our two products, Taiga and [Penpot](https://penpot.app/), together.

### Built with

<div align="center">
    
  [![Python][python-badge]][python-url]
  [![FastAPI][fastapi-badge]][fastapi-url]
  [![Django][django-badge]][django-url]
  [![RxJS][rxjs-badge]][rxjs-url]
  [![Angular][angular-badge]][angular-url]
  [![TypeScript][typescript-badge]][typescript-url]
  [![Jest][jest-badge]][jest-url]
  [![Nx][nx-badge]][nx-url]
  [![PostCSS][postcss-badge]][postcss-url]
    
</div>

## Running the Project

You can run Taiga in two ways: using Docker for a production-like environment or running the backend and frontend separately for development.

### Using Docker (Production-like Environment)

1. Clone the repository:
   ```bash
   git clone https://github.com/taigaio/taiga.git
   cd taiga
   ```

2. Set up environment variables:
   ```bash
   cd docker
   cp .env.example .env
   ```
   
3. Edit the `.env` file to configure your environment (database credentials, email settings, etc.)

4. Start the Docker containers:
   ```bash
   docker-compose up -d
   ```

5. Access Taiga at http://localhost:9000

### Development Setup

#### Backend (Python)

1. Prerequisites:
   - Python >= 3.11
   - PostgreSQL >= 15.x
   - Python development packages (python-dev or python3-dev)
   - libpq-dev packages
   - Redis >= 7.0 (optional)

2. Set up the Python environment:
   ```bash
   cd python/
   python3.11 -m venv --prompt taiga .venv
   source .venv/bin/activate
   pip install --upgrade pip wheel setuptools
   ```

3. Install development tools:
   ```bash
   pip install -r requirements/devel.txt
   ```

4. Set up the Taiga server:
   ```bash
   cd apps/taiga
   pip install -r requirements/devel.txt
   pip install -e .
   cp .env.example.dev .env
   ```

5. Generate the database and sample data:
   ```bash
   ./scripts/regenerate_devel_env.sh
   ```

6. Compile translations:
   ```bash
   python -m taiga i18n compile-catalog
   ```

7. Start the backend in development mode:
   ```bash
   python -m taiga devserve -w
   ```

#### Frontend (JavaScript)

1. Install dependencies:
   ```bash
   cd javascript/
   npm i
   ```

2. Add configuration:
   ```bash
   npm run default-config
   # or cp config.example.json apps/taiga/src/assets/config.json
   ```

3. Run the development server:
   ```bash
   npm start
   ```

4. Access the frontend at the URL shown in the console (typically http://localhost:4200)

## Community

Welcome to our open source software community!

If you'd like to know the news and events about Taiga, go to [Events and Announcements](https://community.taiga.io/c/announcements/5)

If you'd like to help us shape to Taiga, go to [Feature requests](https://community.taiga.io/c/taiga-next/feature-requests/14)

## Code of Conduct

Help us keep the Taiga Community open and inclusive. 

Please read and follow our [Code of Conduct](https://taiga.io/code-of-conduct).

## License

```
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Copyright (c) KALEIDOS INC
```
Please read carefully [our license](https://github.com/taigaio/taiga/blob/main/LICENSE). Every code patch accepted in Taiga codebase is licensed under MPL-2 license.

Taiga is a Kaleidos’ [open source project](https://kaleidos.net/products)


<!-- MARKDOWN LINKS & IMAGES -->
[love-badge]: https://img.shields.io/badge/built%20with-love-red
[python-badge]: https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54
[python-url]: https://www.python.org/
[fastapi-badge]: https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi
[fastapi-url]: https://fastapi.tiangolo.com/
[django-badge]: https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white
[django-url]: https://www.djangoproject.com/
[rxjs-badge]: https://img.shields.io/badge/rxjs-%23B7178C.svg?style=for-the-badge&logo=reactivex&logoColor=white
[rxjs-url]: https://rxjs.dev/
[angular-badge]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[angular-url]: https://angular.io/
[typescript-badge]: https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white
[typescript-url]: https://www.typescriptlang.org/
[jest-badge]: https://img.shields.io/badge/-jest-%23C21325?style=for-the-badge&logo=jest&logoColor=white
[jest-url]: https://jestjs.io/
[nx-badge]: https://img.shields.io/badge/nx-143055?style=for-the-badge&logo=nx&logoColor=white
[nx-url]: https://nx.dev/
[postcss-badge]: https://img.shields.io/badge/postcss-DD3A0A?style=for-the-badge&logo=postcss&logoColor=white
[postcss-url]: https://postcss.org/
