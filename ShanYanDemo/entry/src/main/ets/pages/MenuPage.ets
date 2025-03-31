// -*- coding: utf-8 -*-
// Project    : ShanYanDemo
// File       : MenuPage.ets
// Time       ：2024/10/28
// Author     ：ya dong
// Copyright © 2024 CL. All rights reserved.

import HiLogUtils from '../utils/HiLogUtils'
import AppConfig from '../AppConfig'
import router from '@ohos.router'
import axios, { AxiosResponse } from '@ohos/axios'
import { CheckModel, QueryMobileModel } from '../model/QueryMobileModel'
import { CLResult, CLSDKManager, CLUIConfigure, CLAuthLoginCallBack } from 'shanyansdk'
import { promptAction, window } from '@kit.ArkUI'
import { Security } from '@yd/security'

@Entry
@Component
struct MenuPage {
  @State isOn:boolean = false
  @State message: string = '结果展示：'
  oneKeyResult: CLResult = new CLResult(0, '')
  checkModel: CheckModel = new CheckModel()

  async onPageShow() {
    // 获取传递过来的参数对象
    const params = router.getParams() as Record<string, string>
    if (params) {
      const code: string = params.code as string
      const message: string = params.message as string
      const innerCode: string = params.innerCode as string
      const innerDesc: string = params.innerDesc as string
      if (code === '2000') {
        const phoneNumber: string = params.phoneNumber as string
        const token: string = params.token as string
        this.message = '获取本机校验token : code:' + code + ' msg:' + message + ' innerCode:' + innerCode + ' innerMsg:'
          + innerDesc + 'token: ' + token
        HiLogUtils.info(this.message)
        this.checkModel.code = code
        this.checkModel.token = token
        this.checkModel.phoneNumber = phoneNumber
      } else {
        if (code && code.length > 0) {
          this.checkModel.code = ''
          this.message =
            '本机校验获取token失败 : code:' + code + ' msg:' + message + ' innerCode:' + innerCode + ' innerMsg:' +
              innerDesc
          HiLogUtils.info(this.message)
        }
      }
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Column() {
        Text(this.message)
          .textAlign(TextAlign.Start)
          .padding(20)
          .fontColor(Color.White)
      }
      .width('100%')
      .height('20%')
      .backgroundColor(Color.Black)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Button('初始化', { type: ButtonType.Normal, stateEffect: false })
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin({
            top: 25,
            left: 5,
            right: 5,
            bottom: 5
          })
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(async () => {
            const result: CLResult = await CLSDKManager.init(getContext(this), AppConfig.APP_ID)
            this.message = '初始化 : code:' + result.code + ' msg:' + result.message
            HiLogUtils.info(this.message)
          })

        Button('预取号', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin(5)
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(async () => {
            HiLogUtils.info(' - 预取号')
            let result: CLResult = await CLSDKManager.preGetPhoneNumber()
            this.message =
              '预取号 : code:' + result.code + ' msg:' + result.message + ' innerCode:' +
              result.innerCode
                + ' innerMsg:' + result.innerDesc
            HiLogUtils.info(this.message)
          })

        Button('一键登录', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(20)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin(5)
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(async () => {
            let config = new CLUIConfigure()

            let systemBarProperties: window.SystemBarProperties = {
              statusBarColor: '#ff00ff',
              navigationBarColor: '#00ff00',
              statusBarContentColor: '#ffffff',
              navigationBarContentColor: '#00ffff'
            }
            config.systemBarProperties = systemBarProperties

            config.navTextColor = Color.White
            config.navColor = Color.Pink


            // 登录按钮点击监听事件  （勾选后进入正常的授权登录）
            config.loginClickListener = ({
              onLoginClickStart(context: UIContext) {
                HiLogUtils.info('loginClickListener：开始登录授权')
              }
            , onLoginClickComplete(context: UIContext) {
                HiLogUtils.info('loginClickListener：登录授权结束')
              }
            })
            config.loginPageComponent = authPageComponent

            // 设置授权页返回键监听事件
            config.backPressedListener = ({
              async onBackPressed() {
                HiLogUtils.info('backPressedListener：返回')
                let systemBarProperties: window.SystemBarProperties = {
                  statusBarColor: '#ffffff',
                  statusBarContentColor: '#000000',
                }
                let windowClass: window.Window = await window.getLastWindow(getContext(this))
                await windowClass.setWindowSystemBarProperties(systemBarProperties)
              }
            })

            // 授权按钮监听 1
            config.authLoginListener = ({
              onAuthLoginListener(context: UIContext, callBack: CLAuthLoginCallBack) {
                promptAction.showDialog({
                  message: '是否登录授权',
                  buttons: [
                    {
                      text: '确定',
                      color: '#000000'
                    },
                    {
                      text: '取消',
                      color: '#000000'
                    }
                  ],
                })
                  .then(data => {
                    // 授权回调，通过onAuthLoginCallBack(b:boolean)决定是否继续登录 流程。可以实现二次弹窗确认的功能
                    if (data.index == 0) {
                      CLSDKManager.clearScripCache()
                      callBack.onAuthLoginCallBack(true)
                    } else {
                      callBack.onAuthLoginCallBack(false)
                    }
                  })
              }
            })

            // 设置授权页勾选框和登录按钮的监听事件
            config.checkBoxListener = ({
              onLoginClick() {
                HiLogUtils.info('checkBoxListener：未勾选时点击一键登录回调')
              }
            })
            // 设置授权页勾选框是否勾选的监听事件
            config.checkedChangeListener = ({
              onCheckedChanged(b) {
                HiLogUtils.info('checkedChangeListener：勾选状态改变:' + b)
              }
            })
            config.checkBoxShape = CheckBoxShape.ROUNDED_SQUARE
            config.checkTipText = '没选中- -- ~'

            config.clauses = [{
              text: '同意',
              isProtocol: false,
              fontColor: Color.Black,
              fontSize: 16,
              fontWeight: FontWeight.Bold,
            },
              {
                text: '《**CLAUSE**》',
                isProtocol: true,
                fontColor: Color.Red,
                fontSize: 16,
                fontWeight: FontWeight.Bold,
              },
              {
                text: '、',
                isProtocol: false,
                fontColor: Color.Black,
                fontSize: 16,
                fontWeight: FontWeight.Bold
              },
              {
                text: '自定义协议1',
                isProtocol: true,
                fontColor: Color.Red,
                fontSize: 16,
                fontWeight: FontWeight.Bold,
                url: 'https://www.baidu.com/'
              },
              {
                text: '、',
                isProtocol: false,
                fontColor: Color.Black,
                fontSize: 16,
                fontWeight: FontWeight.Bold
              },
              {
                text: '自定义协议2',
                isProtocol: true,
                fontColor: Color.Red,
                fontSize: 16,
                fontWeight: FontWeight.Bold,
                url: 'https://www.sina.com/'
              },
              {
                text: '并使用本机号码校验',
                isProtocol: false,
                fontColor: Color.Black,
                fontSize: 16,
                fontWeight: FontWeight.Bold
              }]

            config.windowMode = this.isOn
            let dialogViewController = new CustomDialogController({
              builder:(await config.getAuthBuilder()).builder,
              // maskColor:Color.Transparent,
              width:'90%',
              height:'60%',
              offset: { dx:0,dy:'5%' },
              customStyle:false,
              alignment:DialogAlignment.Center,
            })
            config.dialogViewController = dialogViewController

            let pgResult: CLResult =
              await CLSDKManager.quickAuthLoginWithConfigure(config, async (result: CLResult) => {
                if (result.code === 1000) {
                  this.message =
                    '获取token : code:' + result.code + ' msg:' + result.message + ' innerCode:' + result.innerCode
                      + ' innerMsg:' + result.innerDesc + 'token: ' + result.data.get('token')
                  HiLogUtils.info(this.message)
                  CLSDKManager.closeAuthLoginPage()
                  if (result.code === 1000) {
                    this.oneKeyResult = result
                  } else {
                    this.oneKeyResult = new CLResult(0, '')
                  }
                } else {
                  this.message =
                    '获取token失败 : code:' + result.code + ' msg:' + result.message + ' innerCode:' + result.innerCode
                      + ' innerMsg:' + result.innerDesc
                  HiLogUtils.info(this.message)
                  if (result.innerCode !== 1011) {
                    promptAction.showDialog({
                      message: '获取token失败，重试请重新拉起授权页',
                      buttons: [
                        {
                          text: '确定',
                          color: '#000000'
                        }
                      ],
                    })
                      .then(() => {
                        CLSDKManager.closeAuthLoginPage()
                      })
                  }
                }
              })
            this.message =
              '拉起授权页 : code:' + pgResult.code + ' msg:' + pgResult.message + ' innerCode:' + pgResult.innerCode
                + ' innerMsg:' + pgResult.innerDesc
            HiLogUtils.info(this.message)
          })

        Button('置换手机号', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin(5)
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(async () => {
            HiLogUtils.info(' - 置换手机号')
            if (this.oneKeyResult.code === 1000) {
              try {
                let sh256String = 'appId' + AppConfig.APP_ID + 'token' + this.oneKeyResult.data.get('token')
                let sign: string = (await Security.hMacSha256(sh256String, AppConfig.APP_KEY)).hex()

                interface mobileQuery {
                  appId: string,
                  token: string,
                  sign: string
                }

                axios.post<string, AxiosResponse<string>, mobileQuery>(AppConfig.URL_MobileQuery, {
                  appId: AppConfig.APP_ID,
                  token: this.oneKeyResult.data.get('token').toString(),
                  sign: sign
                }, { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })
                  .then(async (response: AxiosResponse<string>) => {
                    let model: QueryMobileModel = JSON.parse(JSON.stringify(response.data))
                    if (model.code === '200000') {
                      try {
                        let mdHexString: string = (await Security.md5(AppConfig.APP_KEY)).hexLower()
                        let phoneNum =
                          await Security.aesDecryptWithHexString(model.data.mobileName, mdHexString.substring(0, 16),
                            mdHexString.substring(16, 32))
                        this.message = '置换手机号 :' + phoneNum.utf8String()
                        HiLogUtils.info(this.message)
                      } catch (e) {
                        HiLogUtils.info('decryptData:' + JSON.stringify(e))
                        this.message = '置换请求异常' + JSON.stringify(e)
                      }
                    } else {
                      HiLogUtils.info('置换请求:' + model.code + ' - ' + model.message)
                      this.message = '置换请求:' + model.code + ' - ' + model.message
                    }
                  })
                  .catch(() => {
                    HiLogUtils.info('置换请求出错:')
                    this.message = '置换请求异常'
                  })
              } catch (e) {
                HiLogUtils.info('axios:' + JSON.stringify(e))
                this.message = '置换请求异常' + JSON.stringify(e)
              }
            } else {
              this.message = '请先获取一键登录token'
              HiLogUtils.info(this.message)
            }
          })

        Button('本机校验', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(20)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin(5)
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(() => {
            router.pushUrl({ url: 'pages/NumberCheckPage' }, router.RouterMode.Standard,
              (err) => {
                if (err) {
                  this.message = '跳转本机号校验出错:' + err.message
                  HiLogUtils.info(this.message)
                } else {
                  this.message = '跳转本机号校验 成功'
                  HiLogUtils.info(this.message)
                }
              })
          })

        Button('校验手机号', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin(5)
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(async () => {
            HiLogUtils.info(' - 校验手机号')
            if (this.checkModel.code === '2000') {
              try {
                let sh256String =
                  'appId' + AppConfig.APP_ID + 'mobile' + this.checkModel.phoneNumber + 'token' + this.checkModel.token
                HiLogUtils.info(sh256String)
                let sign: string = (await Security.hMacSha256(sh256String, AppConfig.APP_KEY)).hex()

                interface mobileValidate {
                  appId: string,
                  token: string,
                  mobile: string,
                  sign: string
                }

                axios.post<string, AxiosResponse<string>, mobileValidate>(AppConfig.URL_MobileValidate, {
                  appId: AppConfig.APP_ID,
                  token: this.checkModel.token,
                  mobile: this.checkModel.phoneNumber,
                  sign: sign
                }, { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } })
                  .then(async (response: AxiosResponse<string>) => {
                    this.message = '本机号校验结果：' + JSON.stringify(response.data)
                    HiLogUtils.info(this.message)
                  })
                  .catch(() => {
                    this.message = '本机号校验出错'
                    HiLogUtils.info(this.message)
                  })
              } catch (e) {
                this.message = '本机号校验出错：' + 'axios:' + JSON.stringify(e)
                HiLogUtils.info(this.message)
              }
            } else {
              this.message = '请先获取本机校验token'
              HiLogUtils.info(this.message)
            }
          })

        Button('清除预取号缓存', { type: ButtonType.Normal, stateEffect: true })
          .fontSize(20)
          .borderRadius(8)
          .width('80%')
          .height(45)
          .margin(5)
          .backgroundColor($r('app.color.start_btn_background'))
          .onClick(async () => {
            this.message = '清除预取号缓存'
            HiLogUtils.info(this.message)
            await CLSDKManager.clearScripCache()
          })
        Row(){
          Text('窗口模式是否开启：')
          Toggle({type:ToggleType.Switch,isOn:false})
            .onChange((isOn:boolean)=>{
              this.isOn = isOn
            })
        }.alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }.height('80%')
      .width('100%')
    }
  }
}

@Builder
export function authPageComponent(): void {
  Column() {
    Text('自定义布局')
      .fontSize(40)
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        center: { anchor: '__container__', align: VerticalAlign.Center },
      }).margin({ top: '300' })
  }.width('100%')
  .height('100%')
  .backgroundColor(Color.White)
  .id('authPageComponent')
}

@Builder
export function clauseComponent(): void {
  Column() {
    Text('自定义协议页标题栏')
      .fontSize(20)
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        center: { anchor: '__container__', align: VerticalAlign.Center },
      })
  }.width('100%')
  .height(50)
  .backgroundColor(0x7f0086d0)
  .id('clauseComponent')
}