// -*- coding: utf-8 -*-
// Project    : ShanYanDemo
// File       : QueryMobileModel.ets
// Time       ：2024/10/29
// Author     ：ya dong
// Copyright © 2024 CL. All rights reserved.

export class QueryMobileModel {
  chargeStatus: number = 0
  message: string = ""
  code: string = ""
  data: QueryMobileData = new QueryMobileData()
}

export class QueryMobileData {
  tradeNo: string = ""
  mobileName: string = ""
}

export class CheckModel {
  code: string = ""
  token: string = ""
  phoneNumber: string = ""
}