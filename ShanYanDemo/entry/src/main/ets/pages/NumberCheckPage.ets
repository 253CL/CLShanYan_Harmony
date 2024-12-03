// -*- coding: utf-8 -*-
// Project    : ShanYanDemo
// File       : NumberCheckPage.ets
// Time       ：2024/10/29
// Author     ：ya dong
// Copyright © 2024 CL. All rights reserved.

import { App, router } from '@kit.ArkUI'
import HiLogUtils from '../utils/HiLogUtils'
import { CLResult, CLSDKManager } from 'shanyansdk'

@Entry
@Component
struct NumberCheckPage {
  @State phoneNumber: string = '16621001237'
  controller: TextInputController = new TextInputController()

  build() {
    Column() {
      Row() {
        Image($r('app.media.back2'))
          .width(50)
          .height(50)
        Text('本机号校验 ')
          .fontSize(20)
      }.alignItems(VerticalAlign.Center)
      .onClick(() => {
        router.back()
      })

      Column() {
        Image($r('app.media.app_icon'))
          .width('100')
          .height('100')
          .borderRadius(16)
          .margin({ bottom: 50 })

        TextInput({ controller: this.controller, placeholder: '请输入手机号', text: this.phoneNumber })
          .width('80%')
          .height(44)
          .type(InputType.PhoneNumber)
          .defaultFocus(true)
          .onChange((value) => {
            this.phoneNumber = value
          })

        Button('本机号认证', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin({ top: 30 })
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(async () => {
            HiLogUtils.info(' - 本机号认证：' + this.phoneNumber)
            let result: CLResult = await CLSDKManager.mobileCheckWithLocalPhoneNumberComplete()
            if (result.code === 2000) {
              router.back({
                url: 'pages/MenuPage', params: {
                  token: result.data.get('token'),
                  code: result.code.toString(),
                  message: result.message,
                  innerCode: result.innerCode.toString(),
                  innerDesc: result.innerDesc,
                  isNCheck: '1',
                  phoneNumber: this.phoneNumber
                }
              })
            } else {
              router.back({
                url: 'pages/MenuPage', params: {
                  code: result.code.toString(),
                  message: result.message,
                  isNCheck: '1',
                  innerCode: result.innerCode.toString(),
                  innerDesc: result.innerDesc
                }
              })
            }
          })
      }.alignItems(HorizontalAlign.Center)
      .margin({ top: 40 })
      .width('100%')
    }.alignItems(HorizontalAlign.Start)
    .height('100%')
    .onClick(() => {
      this.controller.stopEditing()
    })
  }
}