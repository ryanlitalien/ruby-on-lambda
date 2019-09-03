export const actions = {
  async GET_FOODS({ commit }, payload) {
    let number = payload.number || "";
    if(number.length > 0) {
    let url = "https://md6r0oe3g2.execute-api.us-east-1.amazonaws.com/Prod/getphotos";
      url = `${url}?from_number=${encodeURIComponent(number)}`;
      const data = await this.$axios.$get(url, {
        crossdomain: true, withCredentials: false
      });

      commit("SET_FOODS", data);
    }
  }
};

export const getters = {
  foodsList: state => {
    return state.foods;
  }
};

export const mutations = {
  SET_FOODS: (state, foods) => {
    state.foods = foods
  }
};

export const state = () => ({
  foods: []
});

export default {
  actions,
  getters,
  mutations,
  state
};
