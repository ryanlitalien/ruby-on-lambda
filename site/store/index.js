export const actions = {
  async GET_FOODS ({ commit }) {
    // let number = this.$route.params.number || "";
    let number = "";
    let url = "https://md6r0oe3g2.execute-api.us-east-1.amazonaws.com/Prod/getphotos?from_number=" + encodeURIComponent(number);
    const data = await this.$axios.$get(url);

    commit('SET_FOODS', data);
  }
};

export const getters = {
  foodsList: state => {
    return state.foods;
  },
};

export const mutations = {
  SET_FOODS: (state, foods) => {
    state.foods = foods
  },
};

export const state = () => ({
  foods: [],
});

export default {
  actions,
  getters,
  mutations,
  state,
};
