# 캐치야, 물어와! : 특가정보 모음집 '캐치딜'
<div align="center"><img src="/public/img/app_example.png?raw=true" width="500px"></div>

## 팀원
#### 서현석, 김철민, 이인하

## 1. 루비/루비온 제트 정보

<div align="center"><img src="/public/img/jets.png?raw=true" width="500px"></div>

* Ruby : 2.5.3
* Ruby on Jets : 2.3.12
    * Ruby on Jets [[Officual Document]]
    * Ruby on Jets 개념 Tutorial [[클릭]]

## 2. 해당 Repository와의 연결고리
* 안드로이드 Repository : https://github.com/samslow/popStarMomi-FE-V2\
* API 통신 / 소개 페이지 렌더링 / Database Server : https://github.com/kbs4674/catchDeal-BE


## 3. 캐치딜 : 전체적인 백엔드 프로젝트 개요
1. 커뮤니티에는 매일 갖가지 할인행사에 대한 정보를 사람들이 올리면서 공유한다.
2. 그런데 커뮤니티 한 곳이 아닌 여러곳에 정보가 퍼져있다.
3. 그렇다보니 똑같은 정보에 대해 A, C 커뮤니티에는 정보가 있지만, 정작 B 커뮤니티에는 없는 경우가 있다.
4. 백엔드 프로젝트의 역할은 각 커뮤니티에서 특가 정보를 크롤링 후, 앱(apk)과의 통신을 위해 JSON 형식으로 웹페이지에 결과물을 띄우는 것을 담당한다.
5. 크롤링에 대해선 매 시간 단위로 CronJob을 활용하여 Background Job을 통해 크롤링이 진행된다.


## 4. 해당 Repository 내 Jets 프로젝트의 역할
1. 기본적으로 크롤링을 담당한다.
2. AWS Lambda에서는 정해진 Scheduler 시간에 따라 자동으로 크롤링 코드가 있는 함수가 돌아가게 한다.


## 5. 프로젝트 작동 Process
1. 웹 내 크롤링 스케쥴러 작동 원리
<img src="/public/img/process_scheduler.png" width="100%">


## 6. 핵심 코드파일
1. ```app/jobs/hit_product_clien_job.rb``` [[hitProductClienJob]]  클리앙 사이트 크롤링 트리거 (Background Job + CronJob)
2.  ```app/jobs/hit_product_ruliweb_job.rb``` [[hitProductRuliwebJob]]  루리웹 사이트 크롤링 트리거 (Background Job + CronJob)
3. ```app/jobs/hit_product_ppom_job.rb``` [[hitProductPpomJob]] 뽐뿌 사이트 크롤링 트리거 (Background Job + CronJob)
4. ```app/jobs/hit_product_deal_bada_job.rb``` [[hitProductDealBadaJob]] 딜바다 사이트 크롤링 트리거 (Background Job + CronJob)
5. ```app/jobs/hit_product_over_clien_job.rb``` [[hitProductClienJob]]  클리앙 사이트에 있어 크롤링/데이터 생성 목차의 다음 목차부터 크롤링/데이터 수정 Only (Background Job + CronJob)
6.  ```app/jobs/hit_product_over_ruliweb_job.rb``` [[hitProductRuliwebJob]]  루리웹 사이트에 있어 크롤링/데이터 생성 목차의 다음 목차부터 크롤링/데이터 수정 Only (Background Job + CronJob)
7. ```app/jobs/hit_product_over_ppom_job.rb``` [[hitProductPpomJob]] 뽐뿌 사이트에 있어 크롤링/데이터 생성 목차의 다음 목차부터 크롤링/데이터 수정 Only (Background Job + CronJob)
8. ```app/jobs/hit_product_over_deal_bada_job.rb``` [[hitProductDealBadaJob]] 딜바다 사이트에 있어 크롤링/데이터 생성 목차의 다음 목차부터 크롤링/데이터 수정 Only (Background Job + CronJob) 
9. ```app/jobs/auto_delete_job.rb``` [[autoDelete]] 게시글 삭제 트리거 (Background Job + CronJob)
10. ```app/jobs/alive_check_job.rb``` [[aliveCheck]] 원본 게시글이 삭제되었는지 체크 (Background Job)
11. ```app/jobs/hit_product_over_clien_check_job.rb``` [[overClienCheck]] 원본 게시글이 삭제되었는지 체크 (Background Job)





[Officual Document]: https://blog.boltops.com/2019/02/04/aws-lambda-function-jets-introductory-series-part-1
[클릭]: https://kbs4674.tistory.com/100

[hitProductClienJob]: /app/jobs/hit_product_clien_job.rb
[hitProductRuliwebJob]: /app/jobs/hit_product_ruliweb_job.rb
[hitProductPpomJob]: /app/jobs/hit_product_ppom_job.rb
[hitProductDealBadaJob]: /app/jobs/hit_product_deal_bada_job.rb
[hitProductOverClienJob]: /app/jobs/hit_product_over_clien_job.rb
[hitProductOverRuliwebJob]: /app/jobs/hit_product_over_ruliweb_job.rb
[hitProductOverPpomJob]: /app/jobs/hit_product_over_ppom_job.rb
[hitProductOverDealBadaJob]: /app/jobs/hit_product_over_deal_bada_job.rb
[autoDelete]: /app/jobs/auto_delete_job.rb
[aliveCheck]: /app/jobs/alive_check_job.rb
[overClienCheck]: /app/jobs/hit_product_over_clien_check_job.rb