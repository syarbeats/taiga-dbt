# -*- coding: utf-8 -*-
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL

from typing import Any, Dict, Optional

from fastapi import status
from fastapi.exceptions import HTTPException as FastAPIHTTPException

from . import codes


class HTTPException(FastAPIHTTPException):
    def __init__(
        self,
        status_code: int,
        code: str = codes.EX_UNKNOWN,
        detail: Any = None,
        headers: Optional[Dict[str, Any]] = None,
    ) -> None:
        self.code: str = code
        super().__init__(status_code=status_code, detail=detail, headers=headers)


##########################
# HTTP 401: UNAUTHORIZED
##########################


class AuthenticationError(HTTPException):
    def __init__(self, detail: Any = "Invalid token or no active account found with the given credentials"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code=codes.EX_AUTHENTICATION,
            detail=detail,
            headers={"WWW-Authenticate": 'Bearer realm="api"'},
        )


##########################
# HTTP 404: NOT FOUND
##########################

class NotFoundError(HTTPException):
    def __init__(self, detail: Any = "Not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code=codes.EX_NOT_FOUND,
            detail=detail,
        )
