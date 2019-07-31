import axios from 'axios'
export default {
  data: function(){
    return {
        //joinDate: [],
        joinJan: 0, joinFeb: 0, joinMar: 0, joinApr: 0, joinMay: 0, joinJun: 0, joinJul: 0, joinAug: 0, joinSep: 0, joinOct: 0, joinNov: 0, joinDec: 0, withdrawJan: 0, withdrawFeb: 0, withdrawMar: 0, withdrawApr: 0, withdrawMay: 0, withdrawJun: 0, withdrawJul: 0, withdrawAug: 0, withdrawSep: 0, withdrawOct: 0, withdrawNov: 0, withdrawDec: 0,
        joinDate: [],
      }
    },
    mounted: function(){
      this.fetchJoinDate();
    },
    methods: {
      fetchJoinDate(){
        axios.get('/api/people').then((res) => {
          for(let person of res.data.people){
            let joinMonth = person.join_in.substr(5,2);
            joinMonth *=1;
            switch(joinMonth) {
              case 1:
              this.joinJan++;
              break
              case 2:
              this.joinFeb++;
              break
              case 3:
              this.joinMar++;
              break
              case 4:
              this.joinApr++;
              break
              case 5:
              this.joinMay++;
              break
              case 6:
              this.joinJun++;
              break
              case 7:
              this.joinJul++;
              break
              case 8:
              this.joinAug++;
              break
              case 9:
              this.joinSep++;
              break
              case 10:
              this.joinOct++;
              break
              case 11:
              this.joinNov++;
              break
              case 12:
              this.joinDec++;
              break
            }

            let withdrawMonth = person.withdraw_at
            if(withdrawMonth!=null){
              withdrawMonth = person.withdraw_at.substr(5,2);
              withdrawMonth *=1;

              switch(withdrawMonth) {
                case 1:
                this.withdrawJan++;
                break
                case 2:
                this.withdrawFeb++;
                break
                case 3:
                this.withdrawMar++;
                break
                case 4:
                this.withdrawApr++;
                break
                case 5:
                this.withdrawMay++;
                break
                case 6:
                this.withdrawJun++;
                break
                case 7:
                this.withdrawJul++;
                break
                case 8:
                this.withdrawAug++;
                break
                case 9:
                this.withdrawSep++;
                break
                case 10:
                this.withdrawOct++;
                break
                case 11:
                this.withdrawNov++;
                break
                case 12:
                this.withdrawDec++;
                break
              }
            }
          }
          this.joinDate.push({
            "name": "Join in",
            "data": {'1月': this.joinJan, '2月': this.joinFeb, '3月': this.joinMar, '4月': this.joinApr, '5月': this.joinMay, '6月': this.joinJun, '7月': this.joinJul, '8月': this.joinAug, '9月': this.joinSep, '10月': this.joinOct, '11月': this.joinNov, '12月': this.joinDec, }
          })
          this.joinDate.push({
            "name": "Withdraw at",
            "data": {'1月': this.withdrawJan, '2月': this.withdrawFeb, '3月': this.withdrawMar, '4月': this.withdrawApr, '5月': this.withdrawMay, '6月': this.withdrawJun, '7月': this.withdrawJul, '8月': this.withdrawAug, '9月': this.withdrawSep, '10月': this.withdrawOct, '11月': this.withdrawNov, '12月': this.withdrawDec, }
          })
        })
      }
    }
  }