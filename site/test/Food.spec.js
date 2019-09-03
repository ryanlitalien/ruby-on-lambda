import { shallowMount } from '@vue/test-utils';
import Food from "@/components/Food.vue";

const defaultProps = {
  message: 'Pizza',
  public_url: "http://",
  last_modified: "Yesterday"
};

const factory = (data = {}, props = {}) => {
  return shallowMount(Food, {
    data() {
      return { ...data };
    },
    propsData: { ...props }
  });
};

let wrapper;

describe("Food", () => {
  beforeEach(() => {
    wrapper = factory({}, { food: defaultProps });
  });

  it('is a Vue instance', () => {
    expect(wrapper.isVueInstance()).toBeTruthy();
  });

  it('renders the correct message', () => {
    expect(wrapper.element.innerHTML).toMatch(/Pizza/);
  });

  it('renders the correct image', () => {
    expect(wrapper.element.innerHTML).toMatch(/<img src="http:\/\/"/);
  });
});
